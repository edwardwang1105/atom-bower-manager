{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
{Disposable} = require 'atom'
InstalledPackagesPanel = require './installed-packages-panel'
InstallPanel = require './install-panel'

module.exports =
class BowerManagerView extends ScrollView

  @content: ->
    @div class: 'settings-view pane-item', tabindex: -1, =>
      @div class: 'config-menu', outlet: 'sidebar', =>
        @ul class: 'panels-menu nav nav-pills nav-stacked', outlet: 'panelMenu', =>
          @div class: 'panel-menu-separator', outlet: 'menuSeparator'
      @div class: 'panels', outlet: 'panels'

  initialize: ({@uri, activePanelName}={}) ->
    super

    @deferredPanel = {name: activePanelName}
    process.nextTick => @initializePanels()

  dispose: ->
    for name, panel of @panelsByName
      panel.dispose?()
    return

  #TODO Remove both of these post 1.0
  onDidChangeTitle: -> new Disposable()
  onDidChangeModified: -> new Disposable()

  initializePanels: ->
    return if @panels.size > 0

    @panelsByName = {}
    @on 'click', '.panels-menu li a, .panels-packages li a', (e) =>
      @showPanel($(e.target).closest('li').attr('name'))

    @openDotAtom.on 'click', ->
      atom.open(pathsToOpen: [atom.getConfigDirPath()])

    @addCorePanel 'Packages', 'package', -> new InstalledPackagesPanel
    @addCorePanel 'Install', 'plus', => new InstallPanel

    @showDeferredPanel()
    @showPanel('Packages') unless @activePanelName
    @sidebar.width(@sidebar.width()) if @isOnDom()

  serialize: ->
    deserializer: 'BowerManagerView'
    version: 2
    activePanelName: @activePanelName ? @deferredPanel?.name
    uri: @uri

  addCorePanel: (name, iconName, panel) ->
    panelMenuItem = $$ ->
      @li name: name, =>
        @a class: "icon icon-#{iconName}", name
    @menuSeparator.before(panelMenuItem)
    @addPanel(name, panelMenuItem, panel)

  addPanel: (name, panelMenuItem, panelCreateCallback) ->
    @panelCreateCallbacks ?= {}
    @panelCreateCallbacks[name] = panelCreateCallback
    @showDeferredPanel() if @deferredPanel?.name is name

  getOrCreatePanel: (name, options) ->
    panel = @panelsByName?[name]
    # These nested conditionals are not great but I feel like it's the most
    # expedient thing to do - I feel like the "right way" involves refactoring
    # this whole file.
    # unless panel?
    #   callback = @panelCreateCallbacks?[name]
    #
    #   if options?.pack and not callback
    #     callback = =>
    #       # sigh
    #       options.pack.metadata = options.pack
    #       new PackageDetailView(options.pack, @packageManager)
    #
    #   if callback
    #     panel = callback()
    #     @panelsByName ?= {}
    #     @panelsByName[name] = panel
    #     delete @panelCreateCallbacks[name]

    panel

  makePanelMenuActive: (name) ->
    @sidebar.find('.active').removeClass('active')
    @sidebar.find("[name='#{name}']").addClass('active')

  focus: ->
    super

    # Pass focus to panel that is currently visible
    for panel in @panels.children()
      child = $(panel)
      if child.isVisible()
        if view = child.view()
          view.focus()
        else
          child.focus()
        return

  showDeferredPanel: ->
    return unless @deferredPanel?
    {name, options} = @deferredPanel
    @showPanel(name, options)

  showPanel: (name, options) ->
    if panel = @getOrCreatePanel(name, options)
      @panels.children().hide()
      @panels.append(panel) unless $.contains(@panels[0], panel[0])
      panel.beforeShow?(options)
      panel.show()
      panel.focus()
      @makePanelMenuActive(name)
      @activePanelName = name
      @deferredPanel = null
    else
      @deferredPanel = {name, options}

  removePanel: (name) ->
    if panel = @panelsByName?[name]
      panel.remove()
      delete @panelsByName[name]

  getTitle: ->
    "Bower Manager"

  getIconName: ->
    "tools"

  getURI: ->
    @uri

  isEqual: (other) ->
    other instanceof BowerManagerView
