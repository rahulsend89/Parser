Feature: An array

Scenario: Appending to an array
Given I have an empty array
When I add 1 to the array
Then I should have 1 item in the array
And this is undefined statement for test

Scenario: Filtering an array
Given I have an array with the numbers <value1> though <value5>
When I filter the array for even numbers
Then I should have <value2> items in the array
Examples:
|value1|value2|value5|
|1     |2     |5     |
|10    |3     |15  |