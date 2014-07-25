require 'sugar'

module.exports = class DateParser
  constructor: (locale) ->
    # locale is en-US, en-AU, en-UK
    if locale
      Date.setLocale(locale)

    @relativeDate = null

    # excludes common fractions 1/3, 2/3 1/4, 3/4, 1/2
    # must be used at the start of the regex expression
    @excludedCommonFractionsRe = "(?![1-2]\\/3\\s|[1,3]\\/4\\s|1\\/2\\s)"
    # dd/mm/?yy?yy
    # matches 12/05/2014, 5/4/2015, 05/12/14, 05/04
    @dateRe = "\\d{1,2}(?:\\/|\\-)\\d{1,2}(?:(?:\\/|\\-)\\d{2,4})?(?:\\s|\\b)"
    # dayRe # " 3" "15" "22" "31" not "33"
    @dayRe = "(?:^|\\s)(?:(?:(?:[0-2]\\d{1})|(?:[3][01]{1})|([0-9])))(?![\\d])(?:st|nd|rd|th)?"
    @monthRe = "(?:^|\\s)((?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Sept|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?))" # Month 1
    # @spaceRe = ".*?" # Non-greedy match on filler
    @yearRe = "(?:^|\\s)((?:(?:[1]{1}\\d{1}\\d{1}\\d{1})|(?:[2]{1}\\d{3})))(?![\\d])" # Year 1
    @dmyRe = new RegExp(@dayRe + @monthRe + @yearRe, ["i"])
    @dmRe = new RegExp(@dayRe + @monthRe, ["i"])
    @mdyRe = new RegExp(@monthRe + @dayRe + @yearRe, ["i"])
    @mdRe = new RegExp(@monthRe + @dayRe, ["i"])


    @dateWordsRe = new RegExp "today|tomorrow|yesterday", "i"
    # 5:00 | 5.00pm | 14:00 | 3pm | 4pm
    @timeRe = new RegExp "(?:(?:0{0,1}[1-9]|1[0-2])(?::|\\.)[0-5][0-9](?:(?::|\\.)[0-5][0-9]){0,1}\\ {0,1}[aApP][mM])|(?:(?:0{0,1}[0-9]|1[0-9]|2[0-3])(?::|\\.)[0-5][0-9](?:(?::|\\.)[0-5][0-9]){1})|(?:(?:0{0,1}[1-9]|1[0-2]){1}[aApP][mM])"
    # 1 hour ago | 20 mins ago | 4 hours ago
    @timeAgoRe = new RegExp "(?:\\d{1,2}\\s?|an?\\s)(?:(?:ho?u?r?s?)|(?:min(ute)?s?)|(?:day?s?))(?:\\sago)"
    # "(?:(?:0{0,1}[1-9]|1[0-2])(?::|\\.)[0-5][0-9](?:(?::|\\.)[0-5][0-9]){0,1}\\ {0,1}[aApP][mM])|(?:(?:0{0,1}[0-9]|1[0-9]|2[0-3])(?::|\\.)[0-5][0-9](?:(?::|\\.)[0-5][0-9]){0,1})|(?:(?:0{0,1}[1-9]|1[0-2]){0,1}\\[aApP][mM])"


  setDateLocale: (locale) ->
    Date.setLocale(locale)

  setRelativeDate: (date) ->
    @relativeDate = date

  #
  # The text param for these methods is the whole string
  # They should return exactly what they match so it can be discarded from the parent string
  # ..perhaps should return {orig string, match, new string}
  #
  dateWords: (text) ->
    return @getText @dateWordsRe.exec(text)

  # this matches dd/mm/yy(yy) or mm/dd/yy(yy)
  # if excludeCommonFractions is true then it will exclude 1/3, 2/3 1/4, 3/4, 1/2
  # 1/3/2014 is still a valid date
  ddmmyy: (text, excludeCommonFractions) ->
    if excludeCommonFractions
      ddmmyyRe = new RegExp @excludedCommonFractionsRe + @dateRe
    else
      ddmmyyRe = new RegExp @dateRe
    return @getText ddmmyyRe.exec(text)

  dmy: (text) ->
    return @getText @dmyRe.exec(text)

  mdy: (text) ->
    return @getText @mdyRe.exec(text)

  md: (text) ->
    return @getText @mdRe.exec(text)

  dm: (text) ->
    return @getText @dmRe.exec(text)

  time: (text) ->
    @getText @timeRe.exec(text)

  timeAgo: (text) ->
    @getText @timeAgoRe.exec(text)

  getText: (match) ->
    if match?.length > 0
      return match[0].trim()
    else
      return null

  parseDate: (text, excludeCommonFractions) ->
    return @dateWords(text) or @ddmmyy(text, excludeCommonFractions) or @dmy(text) or @mdy(text) or @md(text) or @dm(text)

  parseTime: (text) ->
    return @time(text) or @timeAgo(text)

  cleanTime: (timeStr) ->
    # convert hrs, hr into hours, same for mins
    timeStr = timeStr.replace "hr", "hour"
    timeStr = timeStr.replace "hrs", "hours"
    timeStr = timeStr.replace "mins", "minutes"
    # sugar date does not parse 6.15pm convert to 6:15pm
    return timeStr = timeStr.replace('.', ':')

  cleanDate: (dateStr) ->
    # sugarjs date doesn't like 22nd Feb only 22 Feb
    r =  /[\d]+(st|nd|rd|th)/gi
    return dateStr.replace r, (a, b) -> a.replace b, ''

  parseStringToDateAndTime: (text, excludeCommonFractions) -> 
    dateStr = @parseDate(text, excludeCommonFractions)
    # remove the identified dateStr from the text
    text = text.replace dateStr, ''
    timeStr = @dateParser.parseTime(text)
    return @parseDateAndTimeToDate dateStr, timeStr

  parseDateAndTimeToDate: (dateStr, timeStr) ->
    if dateStr
      dateStr = @cleanDate dateStr
    if timeStr
      timeStr = @cleanTime timeStr

    if not dateStr and @relativeDate
      dateStr = @relativeDate.short()
    # we can use str = '' but date.create will return Invalid Date
    # null will return todays date which at this stage is what we want
    str = null
    if dateStr and timeStr
      str = dateStr + ' ' + timeStr
    else if dateStr
      str = dateStr # .create will return date @ 00:00:00
    else if timeStr
      str = timeStr # .create will return today @ time

    # Use sugarjs Date to parse date String
    date = Date.create(str)
    # for debugging
    # if not d.isValid()
    return date
