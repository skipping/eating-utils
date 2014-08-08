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
      doc.addLine day
      doc.addSection()
      calories = 0
      for meal in meals
        @meal2Text(doc, meal, colours)
        calories += meal.calories
      doc.addSection()
      @writeTotalCalories doc, calories, colours
      doc.addNewLine()

    return doc

  writeHeading: (doc, meals, title) ->
    dateStart = meals.first().date.format('{Weekday} {Month} {dd}, {yyyy}')
    dateFinish = meals[meals.length-1].date.format('{Weekday} {Month} {dd}, {yyyy}')
    title = "| " + title + " -- " + dateStart
    if dateStart isnt dateFinish
      title += " - " + dateFinish

    # +2 to compensate for end of title
    if title.length+2 > doc.lineLength
      title += ' |'
      doc.lineLength = title.length
    else
      title += sprintf('%' + (doc.lineLength - title.length) + 's', ' |')
    
    doc.addTitleSection()
    doc.addLine title
    doc.addTitleSection()
    doc.addNewLine()
    doc.addNewLine()

  writeTotalCalories: (doc, calories, colours) ->
    maxCalorieLength = 7
    cals =  sprintf '%' + (doc.lineLength - maxCalorieLength) + 's cals', calories
    if colours
      cals = cals.green
    doc.addLine cals

  meal2Text: (doc, meal, colours) ->
    if meal._id
      mealStr = sprintf('%2s| ', meal._id)
      if colours
        mealStr = mealStr.grey
    else 
      mealStr = sprintf('   ') + " "
    spacer = ' | '
    time = meal.date.format('{hh}:{mm}{tt}')
    # 6 spaces for id if exists
    # 9 for '1000 cals'
    foodPad = (doc.lineLength - time.length - spacer.length * 2 - 6 - 9)

    foodcals = sprintf('%6s' + spacer + '%-' + foodPad + 's' + spacer + '%4s cals', time, meal.foods, meal.calories)
    if meal.important
      foodcals += " *"
      if colours
        foodcals = foodcals.yellow
    
    mealStr += foodcals
    doc.addLine mealStr


  meal2Console: (meal, colours) ->
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
  constructor: (lineLength) ->
    @lineLength = lineLength or 64
    @text = ''

  addText: (text) ->
    @text = @text.concat(text)
    return @

  addNewLine: ->
    @text = @text.concat('\n')
    return @

  addLine: (text) ->
    @text = @text.concat(text, '\n')
    return @

  addTitleSection: (text) ->
    @addLine Array(@lineLength+1).join('=')
    return @

  addSection: ->
    @addLine Array(@lineLength+1).join('-')
    return @


# # debugger
# blah = new Meals2Text()
# meals = [
#   {
#     _id: 9
#     date: Date.create('yesterday 6:30pm')
#     calories: 700
#     foods: 'Bun Mobile'
#     important: true
#   },
#   {
#     date: Date.create('Today 10am')
#     calories: 900
#     foods: 'Bun Mobile'
#     important: false
#   },
#   {
#     date: Date.create('Today 10.30am')
#     calories: 400
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




