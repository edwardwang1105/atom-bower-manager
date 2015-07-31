{CompositeDisposable} = require 'atom'

ManagerView = null
managerView = null

managerUri = 'atom://bower-manager'

createManagerView = (params) ->
  ManagerView ?= require './bower-manager-view'
  managerView = new ManagerView(params)

openPanel = (panelName, uri) ->
  managerView ?= createManagerView({uri: managerUri})
  managerView.showPanel(panelName, {uri})

module.exports = BowerManager =
  bowerManagerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    atom.workspace.addOpener (uri) ->
      if uri.startsWith(managerUri)
        managerView ?= createManagerView({uri})
        if match = /bower-manager\/([a-z]+)/gi.exec(uri)
          panelName = match[1]
          panelName = panelName[0].toUpperCase() + panelName.slice(1)
          openPanel(panelName, uri)
        managerView

    atom.commands.add 'atom-workspace',
      'bower-manager:open': -> atom.workspace.open(managerUri)
      'bower-manager:install': -> atom.workspace.open("#{managerUri}/install")

  deactivate: ->
    managerView?.dispose()
    managerView?.remove()
    managerView = null
