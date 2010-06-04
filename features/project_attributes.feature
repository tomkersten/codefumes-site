Feature: Viewing Attributes
	Codefumes can store any key value pair that represents either a 
	standard commit payload attribute or a user definitely attribute. Viewing
	these attributes will visually show the user the active attributes being 
	tracked.
	
	Background:
		Given the "twitter_tagger" project has been created
		
	Scenario: Viewing attributes being tracked
		Given the project has 2 unique custom attributes
    When Dora goes to the project's short_uri page
    Then she sees a list of attributes with 2 items in it