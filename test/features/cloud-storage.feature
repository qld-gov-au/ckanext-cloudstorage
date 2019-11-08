@cloud-storage
Feature: Cloud Storage

    Background:
        Given "Admin" as the persona
        When I log in

#    Scenario: Create a new test organisation for subsequent tests
#        Then I go to add new organisation
#        When I fill in "title" with "Test Organisation"
#        When I press "save"
#
#    Scenario: Add a test dataset to the test organisation
#        Then I create a dataset with title "Test dataset" and notes "A description"
#
#    Scenario: Check the test dataset
#        When I go to dataset "test-dataset"
#        Then I take a screenshot

#TODO: add upload file and download file. This may also require a mock s3 or other cloud storage setup
