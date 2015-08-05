_ = require 'lodash'
path = require 'path'
{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

PackageCard = require './package-card'
PackageManager = require './bower-manager'

module.exports =
class InstallPanel extends View
  @content: ->
    @div =>
      @div class: 'section packages', =>
        @div class: 'section-container', =>
          @h1 outlet: 'installHeading', class: 'section-heading icon icon-cloud-download', 'Install Packages'

          @div class: 'text native-key-bindings', tabindex: -1, =>
            @span class: 'icon icon-question'
            @span outlet: 'publishedToText', 'Packages are published to '
            @a class: 'link', outlet: "openBowerIo", "bower.io"
            @span " and are installed to #{path.join(process.env.BOWER_HOME, 'bower_components')}"

          @div class: 'search-container clearfix', =>
            @div class: 'editor-container', =>
              @subview 'searchEditorView', new TextEditorView(mini: true)

          @div outlet: 'searchErrors'
          @div outlet: 'searchMessage', class: 'alert alert-info search-message icon icon-search'
          @div outlet: 'loadingMessage', class: 'alert alert-info featured-message icon icon-hourglass'
          @div outlet: 'resultsContainer', class: 'container package-container'

  initialize: (@packageManager) ->
    @disposables = new CompositeDisposable()

    @bowerIoURL = 'http://bower.io/search/'
    @openBowerIo.on 'click', =>
      require('shell').openExternal(@bowerIoURL)
      false

    @searchMessage.hide()

    @searchEditorView.getModel().setPlaceholderText('Search packages')
    # @handleSearchEvents()

    @loadRegisteredPackages()

  loadRegisteredPackages: ->
    @resultsContainer.empty()
    @loadingMessage.text('Loading registered packages\u2026')
    @loadingMessage.show()

    @packageManager.getRegistered()
      .then (packages) =>
        firstTenPackages = _.take packages, 10
        @loadingMessage.hide()
        @addPackageViews(@resultsContainer, firstTenPackages)

  addPackageViews: (container, packages) ->
    container.empty()

    for pack, index in packages
      packageRow = $$ -> @div class: 'row'
      container.append(packageRow)
      packageRow.append(new PackageCard(pack, @packageManager, back: 'Install'))
