DateParser = require('../src/dateParser')
dp = new DateParser()
describe "DateParser", ->
  describe 'date words', ->
    it "today", ->
      assert.equal dp.dateWords('today beans'), 'today'
    it "tomorrow", ->
      assert.equal dp.dateWords('beans tomorrow'), 'tomorrow'
    it "yesterday", ->
      assert.equal dp.dateWords('beans Yesterday beans'), 'Yesterday'
  describe 'dd/mm/yy', ->
    it "dd/mm", ->
      assert.equal dp.ddmmyy('28/03 beans'), '28/03'
    it "dd/mm/yy", ->
      assert.equal dp.ddmmyy('beans 15/03/14'), '15/03/14'
    it "dd/mm/yyyy", ->
      assert.equal dp.ddmmyy('beans 05/04/2014 beans'), '05/04/2014'
    it "dd-mm", ->
      assert.equal dp.ddmmyy('beans 02-12 beans'), '02-12'
    it "dd/mm end of string", ->
      assert.equal dp.ddmmyy('beans 300c 28/02'), '28/02'
    # it "dd-mm-yyyy", ->
    #   assert.equal null, ddmmyy.dmy('beans 31-03-2014 beans')
  describe 'dmy', ->
    it "start of string", ->
      assert.equal dp.dmy('28 Mar 2014 beans'), '28 Mar 2014'
    it "start of string", ->
      assert.equal dp.dmy('1st August 2014 beans'), '1st August 2014'
    it "end of string", ->
      assert.equal dp.dmy('beans 15th Mar 2014'), '15th Mar 2014'
    it "middle of string", ->
      assert.equal dp.dmy('beans 5 Mar 2014 beans'), '5 Mar 2014'
    it "middle of string low date", ->
      assert.equal dp.dmy('beans 2 Mar 2014 beans'), '2 Mar 2014'
    it "not part of date", ->
      assert.equal null, dp.dmy('beans 33 Mar 2014 beans')
  describe 'mdy', ->
    it "start of string", ->
      assert.equal dp.mdy('Mar 28 2014 beans'), 'Mar 28 2014'
    it "end of string", ->
      assert.equal dp.mdy('beans Mar 31 2014'), 'Mar 31 2014'
    it "middle of string", ->
      assert.equal dp.mdy('beans Mar 5 2014 beans'), 'Mar 5 2014'
    it "not part of date", ->
      assert.equal null, dp.mdy('beans Mar 33 2014 beans')
  describe 'dm', ->
    it "start of string", ->
      assert.equal dp.dm('5 Mar beans'), '5 Mar'
    it "end of string", ->
      assert.equal dp.dm('beans 28 Mar'), '28 Mar'
    it "middle of string", ->
      assert.equal dp.dm('beans 5 mar beans'), '5 mar'
    it "middle of string low date", ->
      assert.equal dp.dm('beans 2 March beans'), '2 March'
    it "not part of date", ->
      assert.equal null, dp.dm('beans 33 Mar beans')
  describe 'md', ->
      it "start of string", ->
        assert.equal dp.md('Mar 28 beans'), 'Mar 28'
      it "end of string", ->
        assert.equal dp.md('beans Mar 31'), 'Mar 31'
      it "middle of string", ->
        assert.equal dp.md('beans Mar 5 3 beans'), 'Mar 5'
      it "not part of date", ->
        assert.equal dp.md('beans Mar 33 beans'), null
  describe 'parseDate', ->
    it "dmy", ->
      assert.equal dp.parseDate('2 sandwich 2pm 33 calories! 28 Feb 2014'), '28 Feb 2014'
    it "mdy", ->
      assert.equal dp.parseDate('Feb 28 2014 2 sandwich 2pm 33 calories! '), 'Feb 28 2014'
    it "dm", ->
      assert.equal dp.parseDate('2 sandwich 2pm 33 calories! 28 Feb 150 calories'), '28 Feb'
    it "md", ->
      assert.equal dp.parseDate('2 sandwich 2pm 33 calories! 150 calories feb 28th'), 'feb 28th'
  describe 'time', ->
    it "hours m", ->
      for i in [1..12]
        str = '2 sandwich ' + i + 'pm 33 calories* feb 28th 150 calories'
        res = i + 'pm'
        assert.equal dp.time(str), res
    it "with : delimeter", ->
        str = '2 sandwich 6:03pm 33 calories* feb 28th 150 calories'
        res = '6:03pm'
        assert.equal dp.time(str), res
    it 'minutes am with . delimeter', ->
      for i in [0..59]
        if i < 10
          i = '0'+ i
        str = '6.' + i + 'am 2 sandwich 33 calories* 150 calories 28/05'
        res = '6.' + i + 'am'
        assert.equal dp.time(str), res
    it 'am time', ->
      str = 'coffee full cream 150 cals 6:15am'
      res = '6:15am'
      assert.equal dp.time(str), res
    it 'with . delmiter', ->
      str = 'yesterday 6.30pm bun mobile 400c'
      res = '6.30pm'
      assert.equal dp.time(str), res
  describe 'timeAgo', ->
    it "1 hour ago", ->
      str = '1 hour ago'
      res = '1 hour ago'
      assert.equal dp.timeAgo(str), res
    it 'middle of string, minutes', ->
      str = 'bun mobile 10 minutes ago 400c'
      res = '10 minutes ago'
      assert.equal dp.timeAgo(str), res

  describe 'parseTime', ->
    it "1 hour ago", ->
      str = '1 hour ago'
      res = '1 hour ago'
      assert.equal dp.parseTime(str), res
    it 'with . delmiter', ->
      str = 'yesterday 6.30pm bun mobile 400c'
      res = '6.30pm'
      assert.equal dp.parseTime(str), res
    it 'with . delmiter', ->
      str = '10 minutes ago bun mobile 400c'
      res = '10 minutes ago'
      assert.equal dp.parseTime(str), res

  describe 'relative date', ->
    it 'yesterday', ->
      dp.relativeDate = Date.create("yesterday")
      str = 'Burger and chips 10pm'
      time = dp.parseTime str
      date = dp.parseDate str
      dateTime = dp.parseDateAndTimeToDate date, time
      assert.equal dateTime.toString(), Date.create("yesterday 10pm").toString()



