require 'sugar'
sprintf   = require("sprintf-js").sprintf
colors      = require 'colors'

module.exports = class Meals2Text

  toConsole: (meals) ->
    out = @createDoc(meals, null, true)
    console.log out.text

  toJSON: (meals) ->
    return JSON.stringify(meals)

  toTxt: (meals, title) ->
    # assumes meals ordered by date
    out = @createDoc(meals, title)
    return out.text

  createDoc: (meals, title, colours) ->
    mealGroups = meals?.groupBy (meal) -> return meal.date.format('{Weekday} {Month} {dd}, {yyyy}')
    doc = new document
    if title
      @writeHeading doc, meals, title

    for day, meals of mealGroups
      doc.addText day
      calories = 0
      for meal in meals
        doc.addLine @meal2Text(meal, colours)
        calories += meal.calories

      @writeTotalCalories doc, calories, colours
      doc.addNewLine()

    return doc

  writeHeading: (doc, meals, title) ->
    dateStart = meals.first().date.format('{Weekday} {Month} {dd}, {yyyy}')
    dateFinish = meals[meals.length-1].date.format('{Weekday} {Month} {dd}, {yyyy}')
    doc.addText title
    doc.addText " -- "
    doc.addText dateStart + " - " + dateFinish
    doc.addSection()
    doc.addNewLine()
    doc.addNewLine()

  writeTotalCalories: (doc,calories, colours) ->
    sep =  sprintf '%61s', "---------"
    cals =  sprintf '%56s cals', calories
    if colours
      sep = sep.grey
      cals = cals.green
    doc.addLine sep
    doc.addLine cals

  meal2Text: (meal, colours) ->
    if meal._id
      mealStr = sprintf('%2s| ', meal._id)
      if colours
        mealStr = mealStr.grey
    else 
      mealStr = sprintf('   ') + " "
    
    time = meal.date.format('{hh}:{mm}{tt}')
    foodcals = sprintf('%6s | %-35s | %4s cals', time, meal.foods, meal.calories)
    if meal.important
      foodcals += " *"
      if colours
        foodcals = foodcals.yellow
    
    mealStr += foodcals
    return mealStr


class document
  constructor: ->
    @text = ''

  addText: (text) ->
    @text = @text.concat(text)
    return @

  addNewLine: ->
    @text = @text.concat('\n')
    return @

  addLine: (text) ->
    @text = @text.concat('\n', text)
    return @

  addSection: ->
    @addLine('------------------------------------')
    return @


# debugger
# blah = new Meals2Text()
# meals = [
#   {
#     _id: 9
#     date: Date.create('Yesterday 6:30pm')
#     calories: 400
#     foods: 'Bun Mobile'
#     important: true
#   },
#   {
#     date: Date.create('Today 10am')
#     calories: 600
#     foods: 'Bun Mobile'
#     important: false
#   },
#   {
#     date: Date.create('Today 10.30am')
#     calories: 300
#     foods: 'beans'
#     important: false
#   }
# ]

# blah.toConsole(meals, "Food Diary")

# fs = require('fs')
# fs.writeFile "foods.txt", blah.toTxt(meals, "Food Diary"), (err) ->
#   if (err) 
#     return console.log(err)
#   console.log('Hello World > foods.txt')

# fs.writeFile "foods.json", blah.toJSON(meals), (err) ->
#   if (err) 
#     return console.log(err)
#   console.log('Hello World > foods.json')




