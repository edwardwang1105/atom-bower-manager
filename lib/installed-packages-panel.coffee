{$$, View} = require 'atom-space-pen-views'

List = require './list'
ListView = require './list-view'
PackageCard = require './package-card'

module.exports =
class InstalledPackagesPanel extends View
  @content: ->
    @div =>
      @div =>
      @section class: 'section', =>
        @div class: 'section-container', =>
          @div class: 'section-heading icon icon-package', =>
            @text 'Installed Packages'
            @span outlet: 'totalPackages', class: 'section-heading-count badge badge-flexible', '…'

          @div outlet: 'updateErrors'

          @section class: 'sub-section installed-packages', =>
            @div outlet: 'installedPackages', class: 'container package-container', =>
              @div class: 'alert alert-info loading-area icon icon-hourglass', "Loading packages…"

  initialize: (@packageManager) ->
    @items = new List('name')
    @itemViews = new ListView(@items, @installedPackages, @createPackageCard)
    @loadPackages()

  loadPackages: ->
    @packageManager.getInstalled()
      .then (@packages) =>
        console.log(@packages)

        @installedPackages.find('.alert.loading-area').remove()
        @items.setItems(@packages)

        # TODO show empty mesage per section

        @updateSectionCounts()

      .catch (error) =>
        console.error error.message, error.stack
        @loadingMessage.hide()
        @featuredErrors.append(new ErrorView(@packageManager, error))

  createPackageCard: (pack) =>
    packageRow = $$ -> @div class: 'row'
    packView = new PackageCard(pack, @packageManager, {back: 'Packages'})
    packageRow.append(packView)
    packageRow

  updateSectionCounts: ->
    @totalPackages.text(@packages.length)
