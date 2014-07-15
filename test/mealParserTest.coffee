# Parser Test
MealParser = require('../src/mealParser')
parser = new MealParser('en-AU')
describe "MealParser", ->
  describe 'parseMeal', ->
    it "2 sandwiches 6:03pm 33 calories! feb 28th 150 calories", ->
      tokens = parser.parseMeal '2 sandwiches 6:03pm 33 calories! feb 28th 150 calories'
      shouldTokens =
        date: new Date ('Fri Feb 28 2014 18:03:00 GMT+1000 (EST)')
        calories: 183
        foods: '2 Sandwiches'
        important: true
      assert.deepEqual tokens, shouldTokens

    it "1/2 a sandwich", ->
      tokens = parser.parseMeal 'apple and 1/2 a sandwich 6:03pm 33 calories! feb 28th 150 calories'
      shouldTokens =
        date: new Date ('Fri Feb 28 2014 18:03:00 GMT+1000 (EST)')
        calories: 183
        foods: 'Apple & 1/2 a Sandwich'
        important: true
      assert.deepEqual tokens, shouldTokens

    it "hotdog 300c en-AU date", ->
      str = 'hotdog 300c 28/02'
      tokens = parser.parseMeal str
      shouldTokens =
        date: new Date('Fri Feb 28 2014 00:00:00 GMT+1000 (EST)')
        calories: 300
        foods: 'Hotdog'
        important: false
      assert.deepEqual tokens, shouldTokens

    it "hotdog 300c with US date", ->
      parser = new MealParser('en-US')
      str = 'hotdog 300c 02/28'
      tokens = parser.parseMeal str
      shouldTokens =
        date: new Date('Fri Feb 28 2014 00:00:00 GMT+1000 (EST)')
        calories: 300
        foods: 'Hotdog'
        important: false
      assert.deepEqual tokens, shouldTokens

    it "yesterday 6.30pm bun mobile! 400c", ->
      parser = new MealParser('en-US')
      str = 'yesterday 6.30pm bun mobile! 400c'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('Yesterday 6:30pm')
        calories: 400
        foods: 'Bun Mobile'
        important: true
      assert.deepEqual tokens, shouldTokens

    it "1hr ago bun mobile! 400c", ->
      parser = new MealParser('en-US')
      str = 'yesterday 6.30pm bun mobile! 400c'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('Yesterday 6:30pm')
        calories: 400
        foods: 'Bun Mobile'
        important: true
      assert.deepEqual tokens, shouldTokens
    
    it "1/4 chicken and chips! 400c", ->
      parser = new MealParser('en-US')
      str = '1/4 chicken and chips! 400c'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('now')
        calories: 400
        foods: '1/4 Chicken & Chips'
        important: true
        
      assert.equal tokens.date.toString(), shouldTokens.date.toString()
      assert.equal tokens.calories, shouldTokens.calories
      assert.equal tokens.foods, shouldTokens.foods
      assert.equal tokens.important, shouldTokens.important

    it "9 cashews 50 20 mins ago", ->
      parser = new MealParser
      str = '9 cashews 50 20 mins ago'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('20 minutes ago').toString()
        calories: 50
        foods: '9 Cashews'
        important: false

      assert.equal tokens.date.toString(), shouldTokens.date.toString()
      assert.equal tokens.calories, shouldTokens.calories
      assert.equal tokens.foods, shouldTokens.foods
      assert.equal tokens.important, shouldTokens.important

    it "10 cashews 10c 20 mins ago", ->
      parser = new MealParser
      str = '10 cashews 10c 20 mins ago'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('20 minutes ago').toString()
        calories: 10
        foods: '10 Cashews'
        important: false

      assert.equal tokens.date.toString(), shouldTokens.date.toString()
      assert.equal tokens.calories, shouldTokens.calories
      assert.equal tokens.foods, shouldTokens.foods
      assert.equal tokens.important, shouldTokens.important


    it "7 ham and pineapple pizzas 2 hours ago 7000!", ->
      parser = new MealParser
      str = '7 ham and pineapple pizzas 2 hours ago 7000!'
      tokens = parser.parseMeal str
      shouldTokens =
        date: Date.create('2 hours ago').toString()
        calories: 7000
        foods: '7 Ham & Pineapple Pizzas'
        important: true

      assert.equal tokens.date.toString(), shouldTokens.date.toString()
      assert.equal tokens.calories, shouldTokens.calories
      assert.equal tokens.foods, shouldTokens.foods
      assert.equal tokens.important, shouldTokens.important
