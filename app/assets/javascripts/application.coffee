#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require handlebars.runtime
#= require underscore.min
#= require_tree .

$('form').on 'click', '.js-remove', (e) -> $(e.currentTarget).parent().remove()

if teams?
  # Group the Teams
  teamHash = _.groupBy teams, (team) -> team.name
  $('.js-teams').typeahead
    source: (team.name for team in teams)
    updater: (team) ->
      # See if the Team is already in the list
      hashTeam = teamHash[team][0]
      unless $("ul.js-teams li input[value=#{hashTeam.id}]").length
        template = JST['templates/team'](hashTeam)
        $('ul.js-teams').append $(template)
      null

if users?
  # Group the users
  userHash = _.groupBy users, (user) -> user.name
  $('.js-users').typeahead
    source: (user.name for user in users)
    updater: (user) ->
      # See if the user is already in the list
      hashUser = userHash[user][0]
      unless $("ul.js-users li input[value=#{hashUser.id}]").length
        template = JST['templates/user'](hashUser)
        $('ul.js-users').append $(template)
      null
