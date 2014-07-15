require 'sugar'

DateParser = require './dateParser'

module.exports = class MealParser
  constructor: (locale) ->
    @dateParser = new DateParser(locale)
    @stripWords = ['calories', 'cal', 'cals', 'at']
    @reNumber = new RegExp("^[0-9][^\\/]*$")

  parseMeal: (text) ->
    # {date, foods, calories, important}
    # text = 2 sandwiches 6:03pm 330 calories! feb 28th
    # everytime we find a match we remove it from the parent string
    # timeStr = @dateParser.parseTime(text)
    # >> timeStr = '6:03pm'
    # text = text.replace timeStr, ''
    # >> text = 2 sandwiches 330 calories! feb 28th
    foods = []
    calories = []

    # we use ! to mark as important because * is a bash expander
    important = text.indexOf('!') > -1 or text.indexOf('*') > -1
    text = text.replace('!', '')
    text = text.replace('*', '')
    text = text.replace('  ', ' ')
    text = text.replace(' and ', " & ")

    # Find Date String
    dateStr = @dateParser.parseDate(text, true)
    # remove date from string
    text = text.replace dateStr, ''

    # Find Time Strings ignoring fractions
    timeStr = @dateParser.parseTime(text)
    # console.log timeStr
    # remove time from string
    text = text.replace timeStr, ''
    # text = text.replace '  ', ' '

    date = @dateParser.parseDateAndTimeToDate dateStr, timeStr

    # We don't need any of these strip words to figure out what the data is so remove them
    for word in @stripWords
      text = text.replace new RegExp("\\b" + word + "\\b","g"), ""

    # remove extra spaces
    text = text.replace(/\s+/g, " ")
    text = text.trim()

    # tokenise
    words = text.split(" ");

    for word in words
      # if its a fraction it wont match and fall through as a food
      number = word.match(@reNumber)
      if number = parseInt(number,10)
        #10cal, 5calories, 10c
        if word.indexOf('c') isnt -1
          calories.push number
          continue
        #quantity
        if number <= 10
          foods.push number
          continue
        calories.push parseInt(number,10)
        continue
      foods.push if word.length > 1 then word.capitalize(true) else word

    # prettify food words
    foods = foods.join(' ')
    # incase they have two calorie strings, apple 50 cals, coffee 100 cals
    calories = calories.sum()

    return { date, foods, calories, important }
