# rcov Copyright (c) 2004-2006 Mauricio Fernandez <mfp@acm.org>
#
# See LEGAL and LICENSE for licensing information.

# NOTE: if you're reading this in the XHTML code coverage report generated by
# rcov, you'll notice that only code inside methods is reported as covered,
# very much like what happens when you run it with --test-unit-only.
# This is due to the fact that we're running rcov on itself: the code below is
# already loaded before coverage tracing is activated, so only code inside
# methods is actually executed under rcov's inspection.

require 'rcov/version'
require 'rcov/formatters'

SCRIPT_LINES__ = {} unless defined? SCRIPT_LINES__

module Rcov

# TODO: Move to Ruby 1.8.6 Backport module
unless RUBY_VERSION =~ /1.9/
  
  class ::String
    
    def lines
      map
    end

  end

end
# Rcov::CoverageInfo is but a wrapper for an array, with some additional
# checks. It is returned by FileStatistics#coverage.
class CoverageInfo
  def initialize(coverage_array)
    @cover = coverage_array.clone
  end

# Return the coverage status for the requested line. There are four possible
# return values:
# * nil if there's no information for the requested line (i.e. it doesn't exist)
# * true if the line was reported by Ruby as executed
# * :inferred if rcov inferred it was executed, despite not being reported 
#   by Ruby.
# * false otherwise, i.e. if it was not reported by Ruby and rcov's
#   heuristics indicated that it was not executed
  def [](line)
    @cover[line]
  end

  def []=(line, val) # :nodoc:
    unless [true, false, :inferred].include? val
      raise RuntimeError, "What does #{val} mean?" 
    end
    return if line < 0 || line >= @cover.size
    @cover[line] = val
  end

# Return an Array holding the code coverage information.
  def to_a
    @cover.clone
  end

  def method_missing(meth, *a, &b) # :nodoc:
    @cover.send(meth, *a, &b)
  end
end

# A FileStatistics object associates a filename to:
# 1. its source code
# 2. the per-line coverage information after correction using rcov's heuristics
# 3. the per-line execution counts
#
# A FileStatistics object can be therefore be built given the filename, the
# associated source code, and an array holding execution counts (i.e. how many
# times each line has been executed).
#
# FileStatistics is relatively intelligent: it handles normal comments,
# <tt>=begin/=end</tt>, heredocs, many multiline-expressions... It uses a
# number of heuristics to determine what is code and what is a comment, and to
# refine the initial (incomplete) coverage information.
#
# Basic usage is as follows:
#  sf = FileStatistics.new("foo.rb", ["puts 1", "if true &&", "   false", 
#                                 "puts 2", "end"],  [1, 1, 0, 0, 0])
#  sf.num_lines        # => 5
#  sf.num_code_lines   # => 5
#  sf.coverage[2]      # => true
#  sf.coverage[3]      # => :inferred
#  sf.code_coverage    # => 0.6
#                    
# The array of strings representing the source code and the array of execution
# counts would normally be obtained from a Rcov::CodeCoverageAnalyzer.
class FileStatistics
  attr_reader :name, :lines, :coverage, :counts
  def initialize(name, lines, counts, comments_run_by_default = false)
    @name = name
    @lines = lines
    initial_coverage = counts.map{|x| (x || 0) > 0 ? true : false }
    @coverage = CoverageInfo.new initial_coverage
    @counts = counts
    @is_begin_comment = nil
    # points to the line defining the heredoc identifier
    # but only if it was marked (we don't care otherwise)
    @heredoc_start = Array.new(lines.size, false)
    @multiline_string_start = Array.new(lines.size, false)
    extend_heredocs
    find_multiline_strings
    precompute_coverage comments_run_by_default
  end

  # Merge code coverage and execution count information.
  # As for code coverage, a line will be considered
  # * covered for sure (true) if it is covered in either +self+ or in the 
  #   +coverage+ array
  # * considered <tt>:inferred</tt> if the neither +self+ nor the +coverage+ array
  #   indicate that it was definitely executed, but it was <tt>inferred</tt>
  #   in either one 
  # * not covered (<tt>false</tt>) if it was uncovered in both
  #
  # Execution counts are just summated on a per-line basis.
  def merge(lines, coverage, counts)
    coverage.each_with_index do |v, idx|
      case @coverage[idx]
      when :inferred 
        @coverage[idx] = v || @coverage[idx]
      when false 
        @coverage[idx] ||= v
      end
    end
    counts.each_with_index{|v, idx| @counts[idx] += v }
    precompute_coverage false
  end

  # Total coverage rate if comments are also considered "executable", given as
  # a fraction, i.e. from 0 to 1.0.
  # A comment is attached to the code following it (RDoc-style): it will be
  # considered executed if the the next statement was executed.
  def total_coverage
    return 0 if @coverage.size == 0
    @coverage.inject(0.0) {|s,a| s + (a ? 1:0) } / @coverage.size
  end

  # Code coverage rate: fraction of lines of code executed, relative to the
  # total amount of lines of code (loc). Returns a float from 0 to 1.0.
  def code_coverage
    indices = (0...@lines.size).select{|i| is_code? i }
    return 0 if indices.size == 0
    count = 0
    indices.each {|i| count += 1 if @coverage[i] }
    1.0 * count / indices.size
  end

  def code_coverage_for_report
    code_coverage * 100
  end

  def total_coverage_for_report
    total_coverage * 100
  end

  # Number of lines of code (loc).
  def num_code_lines
    (0...@lines.size).select{|i| is_code? i}.size
  end

  # Total number of lines.
  def num_lines
    @lines.size
  end

  # Returns true if the given line number corresponds to code, as opposed to a
  # comment (either # or =begin/=end blocks).
  def is_code?(lineno)
    unless @is_begin_comment
      @is_begin_comment = Array.new(@lines.size, false)
      pending = []
      state = :code
      @lines.each_with_index do |line, index|
        case state
        when :code
          if /^=begin\b/ =~ line
            state = :comment
            pending << index
          end
        when :comment
          pending << index
          if /^=end\b/ =~ line
            state = :code
            pending.each{|idx| @is_begin_comment[idx] = true}
            pending.clear
          end
        end
      end
    end
    @lines[lineno] && !@is_begin_comment[lineno] && 
      @lines[lineno] !~ /^\s*(#|$)/ 
  end

  private

  def find_multiline_strings
    state = :awaiting_string
    wanted_delimiter = nil
    string_begin_line = 0
    @lines.each_with_index do |line, i|
      matching_delimiters = Hash.new{|h,k| k} 
      matching_delimiters.update("{" => "}", "[" => "]", "(" => ")")
      case state
      when :awaiting_string
        # very conservative, doesn't consider the last delimited string but
        # only the very first one
        if md = /^[^#]*%(?:[qQ])?(.)/.match(line)
          wanted_delimiter = /(?!\\).#{Regexp.escape(matching_delimiters[md[1]])}/
          # check if closed on the very same line
          # conservative again, we might have several quoted strings with the
          # same delimiter on the same line, leaving the last one open
          unless wanted_delimiter.match(md.post_match)
            state = :want_end_delimiter
            string_begin_line = i
          end
        end
      when :want_end_delimiter
        @multiline_string_start[i] = string_begin_line
        if wanted_delimiter.match(line)
          state = :awaiting_string
        end
      end
    end
  end

  def precompute_coverage(comments_run_by_default = true)
    changed = false
    lastidx = lines.size - 1
    if (!is_code?(lastidx) || /^__END__$/ =~ @lines[-1]) && !@coverage[lastidx]
      # mark the last block of comments
      @coverage[lastidx] ||= :inferred
      (lastidx-1).downto(0) do |i|
        break if is_code?(i)
        @coverage[i] ||= :inferred
      end
    end
    (0...lines.size).each do |i|
      next if @coverage[i]
      line = @lines[i]
      if /^\s*(begin|ensure|else|case)\s*(?:#.*)?$/ =~ line && next_expr_marked?(i) or
        /^\s*(?:end|\})\s*(?:#.*)?$/ =~ line && prev_expr_marked?(i) or
        /^\s*(?:end\b|\})/ =~ line && prev_expr_marked?(i) && next_expr_marked?(i) or
        /^\s*rescue\b/ =~ line && next_expr_marked?(i) or
        /(do|\{)\s*(\|[^|]*\|\s*)?(?:#.*)?$/ =~ line && next_expr_marked?(i) or
        prev_expr_continued?(i) && prev_expr_marked?(i) or
        comments_run_by_default && !is_code?(i) or 
        /^\s*((\)|\]|\})\s*)+(?:#.*)?$/ =~ line && prev_expr_marked?(i) or
        prev_expr_continued?(i+1) && next_expr_marked?(i)
        @coverage[i] ||= :inferred
        changed = true
      end
    end
    (@lines.size-1).downto(0) do |i|
      next if @coverage[i]
      if !is_code?(i) and @coverage[i+1] 
        @coverage[i] = :inferred
        changed = true
      end
    end

    extend_heredocs if changed

    # if there was any change, we have to recompute; we'll eventually
    # reach a fixed point and stop there
    precompute_coverage(comments_run_by_default) if changed
  end

  require 'strscan'
  def extend_heredocs
    i = 0
    while i < @lines.size
      unless is_code? i
        i += 1
        next
      end
      #FIXME: using a restrictive regexp so that only <<[A-Z_a-z]\w*
      # matches when unquoted, so as to avoid problems with 1<<2
      # (keep in mind that whereas puts <<2 is valid, puts 1<<2 is a
      # parse error, but  a = 1<<2  is of course fine)
      scanner = StringScanner.new(@lines[i])
      j = k = i
      loop do
        scanned_text = scanner.search_full(/<<(-?)(?:(['"`])((?:(?!\2).)+)\2|([A-Z_a-z]\w*))/, 
                                           true, true)
        # k is the first line after the end delimiter for the last heredoc
        # scanned so far
        unless scanner.matched?
          i = k
          break
        end
        term = scanner[3] || scanner[4]
        # try to ignore symbolic bitshifts like  1<<LSHIFT
        ident_text = "<<#{scanner[1]}#{scanner[2]}#{term}#{scanner[2]}"
        if scanned_text[/\d+\s*#{Regexp.escape(ident_text)}/]
          # it was preceded by a number, ignore
          i = k
          break
        end
        must_mark = []
        end_of_heredoc = (scanner[1] == "-") ? 
               /^\s*#{Regexp.escape(term)}$/ : /^#{Regexp.escape(term)}$/
        loop do
          break if j == @lines.size
          must_mark << j
          if end_of_heredoc =~ @lines[j]
            must_mark.each do |n|
              @heredoc_start[n] = i
            end
            if (must_mark + [i]).any?{|lineidx| @coverage[lineidx]}
              @coverage[i] ||= :inferred
              must_mark.each{|lineidx| @coverage[lineidx] ||= :inferred}
            end
            # move the "first line after heredocs" index
            k = (j += 1)
            break
          end
          j += 1
        end
      end

      i += 1
    end
  end

  def next_expr_marked?(lineno)
    return false if lineno >= @lines.size
    found = false
    idx = (lineno+1).upto(@lines.size-1) do |i|
      next unless is_code? i
      found = true
      break i
    end
    return false unless found
    @coverage[idx]
  end

  def prev_expr_marked?(lineno)
    return false if lineno <= 0
    found = false
    idx = (lineno-1).downto(0) do |i|
      next unless is_code? i
      found = true
      break i
    end
    return false unless found
    @coverage[idx]
  end

  def prev_expr_continued?(lineno)
    return false if lineno <= 0
    return false if lineno >= @lines.size
    found = false
    if @multiline_string_start[lineno] && 
      @multiline_string_start[lineno] < lineno
      return true
    end
    # find index of previous code line
    idx = (lineno-1).downto(0) do |i|
      if @heredoc_start[i]
        found = true
        break @heredoc_start[i] 
      end
      next unless is_code? i
      found = true
      break i
    end
    return false unless found
    #TODO: write a comprehensive list
    if is_code?(lineno) && /^\s*((\)|\]|\})\s*)+(?:#.*)?$/.match(@lines[lineno])
      return true
    end
    #FIXME: / matches regexps too
    # the following regexp tries to reject #{interpolation}
    r = /(,|\.|\+|-|\*|\/|<|>|%|&&|\|\||<<|\(|\[|\{|=|and|or|\\)\s*(?:#(?![{$@]).*)?$/.match @lines[idx]
    # try to see if a multi-line expression with opening, closing delimiters
    # started on that line
    [%w!( )!].each do |opening_str, closing_str| 
      # conservative: only consider nesting levels opened in that line, not
      # previous ones too.
      # next regexp considers interpolation too
      line = @lines[idx].gsub(/#(?![{$@]).*$/, "")
      opened = line.scan(/#{Regexp.escape(opening_str)}/).size
      closed = line.scan(/#{Regexp.escape(closing_str)}/).size
      return true if opened - closed > 0
    end
    if /(do|\{)\s*\|[^|]*\|\s*(?:#.*)?$/.match @lines[idx]
      return false
    end

    r
  end
end


autoload :RCOV__, "rcov/lowlevel.rb"

class DifferentialAnalyzer
  require 'thread'
  @@mutex = Mutex.new

  def initialize(install_hook_meth, remove_hook_meth, reset_meth)
    @cache_state = :wait
    @start_raw_data = data_default
    @end_raw_data = data_default
    @aggregated_data = data_default
    @install_hook_meth = install_hook_meth
    @remove_hook_meth= remove_hook_meth
    @reset_meth= reset_meth
  end

  # Execute the code in the given block, monitoring it in order to gather
  # information about which code was executed.
  def run_hooked
    install_hook
    yield
  ensure
    remove_hook
  end

  # Start monitoring execution to gather information. Such data will be
  # collected until #remove_hook is called.
  #
  # Use #run_hooked instead if possible.
  def install_hook
    @start_raw_data = raw_data_absolute
    Rcov::RCOV__.send(@install_hook_meth)
    @cache_state = :hooked
    @@mutex.synchronize{ self.class.hook_level += 1 }
  end

  # Stop collecting information.
  # #remove_hook will also stop collecting info if it is run inside a
  # #run_hooked block.
  def remove_hook
    @@mutex.synchronize do 
      self.class.hook_level -= 1
      Rcov::RCOV__.send(@remove_hook_meth) if self.class.hook_level == 0
    end
    @end_raw_data = raw_data_absolute
    @cache_state = :done
    # force computation of the stats for the traced code in this run;
    # we cannot simply let it be if self.class.hook_level == 0 because 
    # some other analyzer could install a hook, causing the raw_data_absolute
    # to change again.
    # TODO: lazy computation of raw_data_relative, only when the hook gets
    # activated again.
    raw_data_relative
  end

  # Remove the data collected so far. Further collection will start from
  # scratch.
  def reset
    @@mutex.synchronize do
      if self.class.hook_level == 0
        # Unfortunately there's no way to report this as covered with rcov:
        # if we run the tests under rcov self.class.hook_level will be >= 1 !
        # It is however executed when we run the tests normally.
        Rcov::RCOV__.send(@reset_meth)
        @start_raw_data = data_default
        @end_raw_data = data_default
      else
        @start_raw_data = @end_raw_data = raw_data_absolute
      end
      @raw_data_relative = data_default
      @aggregated_data = data_default
    end
  end

  protected

  def data_default
    raise "must be implemented by the subclass"
  end
    
  def self.hook_level
    raise "must be implemented by the subclass"
  end

  def raw_data_absolute
    raise "must be implemented by the subclass"
  end

  def aggregate_data(aggregated_data, delta)
    raise "must be implemented by the subclass"
  end

  def compute_raw_data_difference(first, last)
    raise "must be implemented by the subclass"
  end

  private
  def raw_data_relative
    case @cache_state
    when :wait
      return @aggregated_data
    when :hooked
      new_start = raw_data_absolute
      new_diff = compute_raw_data_difference(@start_raw_data, new_start)
      @start_raw_data = new_start
    when :done
      @cache_state = :wait
      new_diff = compute_raw_data_difference(@start_raw_data, 
                                             @end_raw_data)
    end

    aggregate_data(@aggregated_data, new_diff)

    @aggregated_data
  end
  
end

# A CodeCoverageAnalyzer is responsible for tracing code execution and
# returning code coverage and execution count information.
#
# Note that you must <tt>require 'rcov'</tt> before the code you want to
# analyze is parsed (i.e. before it gets loaded or required). You can do that
# by either invoking ruby with the <tt>-rrcov</tt> command-line option or
# just:
#  require 'rcov'
#  require 'mycode'
#  # ....
#
# == Example
#
#  analyzer = Rcov::CodeCoverageAnalyzer.new
#  analyzer.run_hooked do 
#    do_foo  
#    # all the code executed as a result of this method call is traced
#  end
#  # ....
#  
#  analyzer.run_hooked do 
#    do_bar
#    # the code coverage information generated in this run is aggregated
#    # to the previously recorded one
#  end
#
#  analyzer.analyzed_files   # => ["foo.rb", "bar.rb", ... ]
#  lines, marked_info, count_info = analyzer.data("foo.rb")
#
# In this example, two pieces of code are monitored, and the data generated in
# both runs are aggregated. +lines+ is an array of strings representing the 
# source code of <tt>foo.rb</tt>. +marked_info+ is an array holding false,
# true values indicating whether the corresponding lines of code were reported
# as executed by Ruby. +count_info+ is an array of integers representing how
# many times each line of code has been executed (more precisely, how many
# events where reported by Ruby --- a single line might correspond to several
# events, e.g. many method calls).
#
# You can have several CodeCoverageAnalyzer objects at a time, and it is
# possible to nest the #run_hooked / #install_hook/#remove_hook blocks: each
# analyzer will manage its data separately. Note however that no special
# provision is taken to ignore code executed "inside" the CodeCoverageAnalyzer
# class. At any rate this will not pose a problem since it's easy to ignore it
# manually: just don't do
#   lines, coverage, counts = analyzer.data("/path/to/lib/rcov.rb")
# if you're not interested in that information.
class CodeCoverageAnalyzer < DifferentialAnalyzer
  @hook_level = 0
  # defined this way instead of attr_accessor so that it's covered
  def self.hook_level      # :nodoc:
    @hook_level 
  end   
  def self.hook_level=(x)  # :nodoc: 
    @hook_level = x 
  end 

  def initialize
    @script_lines__ = SCRIPT_LINES__
    super(:install_coverage_hook, :remove_coverage_hook,
          :reset_coverage)
  end
  
  # Return an array with the names of the files whose code was executed inside
  # the block given to #run_hooked or between #install_hook and #remove_hook.
  def analyzed_files
    update_script_lines__
    raw_data_relative.select do |file, lines|
      @script_lines__.has_key?(file)
    end.map{|fname,| fname}
  end

  # Return the available data about the requested file, or nil if none of its
  # code was executed or it cannot be found.
  # The return value is an array with three elements:
  #  lines, marked_info, count_info = analyzer.data("foo.rb")
  # +lines+ is an array of strings representing the 
  # source code of <tt>foo.rb</tt>. +marked_info+ is an array holding false,
  # true values indicating whether the corresponding lines of code were reported
  # as executed by Ruby. +count_info+ is an array of integers representing how
  # many times each line of code has been executed (more precisely, how many
  # events where reported by Ruby --- a single line might correspond to several
  # events, e.g. many method calls).
  #
  # The returned data corresponds to the aggregation of all the statistics
  # collected in each #run_hooked or #install_hook/#remove_hook runs. You can
  # reset the data at any time with #reset to start from scratch.
  def data(filename)
    raw_data = raw_data_relative
    update_script_lines__
    unless @script_lines__.has_key?(filename) && 
           raw_data.has_key?(filename)
      return nil 
    end
    refine_coverage_info(@script_lines__[filename], raw_data[filename])
  end

  # Data for the first file matching the given regexp.
  # See #data.
  def data_matching(filename_re)
    raw_data = raw_data_relative
    update_script_lines__

    match = raw_data.keys.sort.grep(filename_re).first
    return nil unless match

    refine_coverage_info(@script_lines__[match], raw_data[match])
  end

  # Execute the code in the given block, monitoring it in order to gather
  # information about which code was executed.
  def run_hooked; super end

  # Start monitoring execution to gather code coverage and execution count
  # information. Such data will be collected until #remove_hook is called.
  #
  # Use #run_hooked instead if possible.
  def install_hook; super end

  # Stop collecting code coverage and execution count information.
  # #remove_hook will also stop collecting info if it is run inside a
  # #run_hooked block.
  def remove_hook; super end

  # Remove the data collected so far. The coverage and execution count
  # "history" will be erased, and further collection will start from scratch:
  # no code is considered executed, and therefore all execution counts are 0.
  # Right after #reset, #analyzed_files will return an empty array, and
  # #data(filename) will return nil.
  def reset; super end

  def dump_coverage_info(formatters) # :nodoc:
    update_script_lines__
    raw_data_relative.each do |file, lines|
      next if @script_lines__.has_key?(file) == false
      lines = @script_lines__[file]
      raw_coverage_array = raw_data_relative[file]

      line_info, marked_info, 
        count_info = refine_coverage_info(lines, raw_coverage_array)
      formatters.each do |formatter|
        formatter.add_file(file, line_info, marked_info, count_info)
      end
    end
    formatters.each{|formatter| formatter.execute}
  end

  private

  def data_default; {} end

  def raw_data_absolute
    Rcov::RCOV__.generate_coverage_info
  end

  def aggregate_data(aggregated_data, delta)
    delta.each_pair do |file, cov_arr|
      dest = (aggregated_data[file] ||= Array.new(cov_arr.size, 0))
      cov_arr.each_with_index{|x,i| dest[i] += x}
    end
  end

  def compute_raw_data_difference(first, last)
    difference = {}
    last.each_pair do |fname, cov_arr|
      unless first.has_key?(fname)
        difference[fname] = cov_arr.clone
      else
        orig_arr = first[fname]
        diff_arr = Array.new(cov_arr.size, 0)
        changed = false
        cov_arr.each_with_index do |x, i|
          diff_arr[i] = diff = (x || 0) - (orig_arr[i] || 0)
          changed = true if diff != 0
        end
        difference[fname] = diff_arr if changed
      end
    end
    difference
  end


  def refine_coverage_info(lines, covers)
    marked_info = []
    count_info = []
    lines.size.times do |i|
      c = covers[i]
      marked_info << ((c && c > 0) ? true : false)
      count_info << (c || 0)
    end

    script_lines_workaround(lines, marked_info, count_info)
  end

  # Try to detect repeated data, based on observed repetitions in line_info:
  # this is a workaround for SCRIPT_LINES__[filename] including as many copies
  # of the file as the number of times it was parsed.
  def script_lines_workaround(line_info, coverage_info, count_info)
    is_repeated = lambda do |div|
      n = line_info.size / div
      break false unless line_info.size % div == 0 && n > 1
      different = false
      n.times do |i|
        
        things = (0...div).map { |j| line_info[i + j * n] }
        if things.uniq.size != 1
          different = true
          break
        end
      end

      ! different
    end

    factors = braindead_factorize(line_info.size)
    factors.each do |n|
      if is_repeated[n]
        line_info = line_info[0, line_info.size / n]
        coverage_info = coverage_info[0, coverage_info.size / n]
        count_info = count_info[0, count_info.size / n]
      end
    end if factors.size > 1   # don't even try if it's prime
    
    [line_info, coverage_info, count_info]
  end

  def braindead_factorize(num)
    return [0] if num == 0
    return [-1] + braindead_factorize(-num) if num < 0
    factors = []
    while num % 2 == 0
      factors << 2
      num /= 2
    end
    size = num
    n = 3
    max = Math.sqrt(num)
    while n <= max && n <= size
      while size % n == 0
        size /= n
        factors << n
      end
      n += 2
    end
    factors << size if size != 1
    factors
  end

  def update_script_lines__
    @script_lines__ = @script_lines__.merge(SCRIPT_LINES__)
  end

  public
  def marshal_dump # :nodoc:
    # @script_lines__ is updated just before serialization so as to avoid
    # missing files in SCRIPT_LINES__
    ivs = {}
    update_script_lines__
    instance_variables.each{|iv| ivs[iv] = instance_variable_get(iv)}
    ivs
  end

  def marshal_load(ivs) # :nodoc:
    ivs.each_pair{|iv, val| instance_variable_set(iv, val)}
  end

end # CodeCoverageAnalyzer

# A CallSiteAnalyzer can be used to obtain information about:
# * where a method is defined ("+defsite+")
# * where a method was called from ("+callsite+")
#
# == Example
# <tt>example.rb</tt>:
#  class X
#    def f1; f2 end
#    def f2; 1 + 1 end
#    def f3; f1 end
#  end
#
#  analyzer = Rcov::CallSiteAnalyzer.new
#  x = X.new
#  analyzer.run_hooked do 
#    x.f1 
#  end
#  # ....
#  
#  analyzer.run_hooked do 
#    x.f3
#    # the information generated in this run is aggregated
#    # to the previously recorded one
#  end
#
#  analyzer.analyzed_classes        # => ["X", ... ]
#  analyzer.methods_for_class("X")  # => ["f1", "f2", "f3"]
#  analyzer.defsite("X#f1")         # => DefSite object
#  analyzer.callsites("X#f2")       # => hash with CallSite => count
#                                   #    associations
#  defsite = analyzer.defsite("X#f1")
#  defsite.file                     # => "example.rb"
#  defsite.line                     # => 2
#
# You can have several CallSiteAnalyzer objects at a time, and it is
# possible to nest the #run_hooked / #install_hook/#remove_hook blocks: each
# analyzer will manage its data separately. Note however that no special
# provision is taken to ignore code executed "inside" the CallSiteAnalyzer
# class. 
#
# +defsite+ information is only available for methods that were called under
# the inspection of the CallSiteAnalyzer, i.o.w. you will only have +defsite+
# information for those methods for which callsite information is
# available.
class CallSiteAnalyzer < DifferentialAnalyzer
  # A method definition site.
  class DefSite < Struct.new(:file, :line)
  end
  
  # Object representing a method call site.
  # It corresponds to a part of the callstack starting from the context that
  # called the method.   
  class CallSite < Struct.new(:backtrace)
    # The depth of a CallSite is the number of stack frames
    # whose information is included in the CallSite object.
    def depth
      backtrace.size
    end
    
    # File where the method call originated.
    # Might return +nil+ or "" if it is not meaningful (C extensions, etc).
    def file(level = 0)
      stack_frame = backtrace[level]
      stack_frame ? stack_frame[2] : nil
    end

    # Line where the method call originated.
    # Might return +nil+ or 0 if it is not meaningful (C extensions, etc).
    def line(level = 0)
      stack_frame = backtrace[level]
      stack_frame ? stack_frame[3] : nil
    end

    # Name of the method where the call originated.
    # Returns +nil+ if the call originated in +toplevel+.
    # Might return +nil+ if it could not be determined.
    def calling_method(level = 0)
      stack_frame = backtrace[level]
      stack_frame ? stack_frame[1] : nil
    end

    # Name of the class holding the method where the call originated.
    # Might return +nil+ if it could not be determined.
    def calling_class(level = 0)
      stack_frame = backtrace[level]
      stack_frame ? stack_frame[0] : nil
    end
  end

  @hook_level = 0
  # defined this way instead of attr_accessor so that it's covered
  def self.hook_level      # :nodoc:
    @hook_level 
  end   
  def self.hook_level=(x)  # :nodoc: 
    @hook_level = x 
  end 

  def initialize
    super(:install_callsite_hook, :remove_callsite_hook,
          :reset_callsite)
  end

  # Classes whose methods have been called.
  # Returns an array of strings describing the classes (just klass.to_s for
  # each of them). Singleton classes are rendered as:
  #   #<Class:MyNamespace::MyClass>
  def analyzed_classes
    raw_data_relative.first.keys.map{|klass, meth| klass}.uniq.sort
  end

  # Methods that were called for the given class. See #analyzed_classes for
  # the notation used for singleton classes.
  # Returns an array of strings or +nil+
  def methods_for_class(classname)
    a = raw_data_relative.first.keys.select{|kl,_| kl == classname}.map{|_,meth| meth}.sort
    a.empty? ? nil : a
  end
  alias_method :analyzed_methods, :methods_for_class

  # Returns a hash with <tt>CallSite => call count</tt> associations or +nil+
  # Can be called in two ways:
  #   analyzer.callsites("Foo#f1")         # instance method
  #   analyzer.callsites("Foo.g1")         # singleton method of the class
  # or
  #   analyzer.callsites("Foo", "f1")
  #   analyzer.callsites("#<class:Foo>", "g1")
  def callsites(classname_or_fullname, methodname = nil)
    rawsites = raw_data_relative.first[expand_name(classname_or_fullname, methodname)]
    return nil unless rawsites
    ret = {}
    # could be a job for inject but it's slow and I don't mind the extra loc
    rawsites.each_pair do |backtrace, count|
      ret[CallSite.new(backtrace)] = count
    end
    ret
  end

  # Returns a DefSite object corresponding to the given method
  # Can be called in two ways:
  #   analyzer.defsite("Foo#f1")         # instance method
  #   analyzer.defsite("Foo.g1")         # singleton method of the class
  # or
  #   analyzer.defsite("Foo", "f1")
  #   analyzer.defsite("#<class:Foo>", "g1")
  def defsite(classname_or_fullname, methodname = nil)
    file, line = raw_data_relative[1][expand_name(classname_or_fullname, methodname)]
    return nil unless file && line
    DefSite.new(file, line)
  end

  private

  def expand_name(classname_or_fullname, methodname = nil)
    if methodname.nil?
      case classname_or_fullname
      when /(.*)#(.*)/ then classname, methodname = $1, $2
      when /(.*)\.(.*)/ then classname, methodname = "#<Class:#{$1}>", $2
      else
        raise ArgumentError, "Incorrect method name"
      end

      return [classname, methodname]
    end

    [classname_or_fullname, methodname]
  end

  def data_default; [{}, {}] end

  def raw_data_absolute
    raw, method_def_site = RCOV__.generate_callsite_info
    ret1 = {}
    ret2 = {}
    raw.each_pair do |(klass, method), hash|
      begin  
        key = [klass.to_s, method.to_s]
        ret1[key] = hash.clone #Marshal.load(Marshal.dump(hash))
        ret2[key] = method_def_site[[klass, method]]
      #rescue Exception
      end
    end
    
    [ret1, ret2]
  end

  def aggregate_data(aggregated_data, delta)
    callsites1, defsites1 = aggregated_data
    callsites2, defsites2 = delta
    
    callsites2.each_pair do |(klass, method), hash|
      dest_hash = (callsites1[[klass, method]] ||= {})
      hash.each_pair do |callsite, count|
        dest_hash[callsite] ||= 0
        dest_hash[callsite] += count
      end
    end

    defsites1.update(defsites2)
  end

  def compute_raw_data_difference(first, last)
    difference = {}
    default = Hash.new(0)

    callsites1, defsites1 = *first
    callsites2, defsites2 = *last
    
    callsites2.each_pair do |(klass, method), hash|
      old_hash = callsites1[[klass, method]] || default
      hash.each_pair do |callsite, count|
        diff = hash[callsite] - (old_hash[callsite] || 0)
        if diff > 0
          difference[[klass, method]] ||= {}
          difference[[klass, method]][callsite] = diff
        end
      end
    end
    
    [difference, defsites1.update(defsites2)]
  end

end

end