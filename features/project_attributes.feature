Feature: Viewing Attributes
	Codefumes can store any key value pair that represents either a 
	standard commit payload attribute or a user definitely attribute. Viewing
	these attributes will visually show the user the active attributes being 
	tracked.
	
	Background:
		Given the "twitter_tagger" project has been created
		Given the project has 2 unique custom attributes
		
	Scenario: Viewing attributes being tracked
		When Dora goes to the project's short_uri page
		Then she sees a list of attributes with 2 items in it

	Scenario: Viewing a specific attribute
		When Dora goes to the project's short_uri page
		And she follows the link to view temperature_attribute
		Then she sees temperature_attribute name selected
		And chairs_attribute should not be selected