{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class PackageCard extends View

  @content: ({name, description, version, homepage}) ->
    description ?= ''

    @div class: 'package-card col-lg-8', =>
      @div class: 'stats pull-right', =>
        @span class: "stats-item", =>
          @span class: 'icon icon-versions'
          @span outlet: 'versionValue', class: 'value', String(version)

        @span class: 'stats-item', =>
          @span class: 'icon icon-cloud-download'
          @span outlet: 'downloadCount', class: 'value'

      @div class: 'body', =>
        @h4 class: 'card-name', =>
          @a outlet: 'packageName', name
          @span ' '
          @span class: 'deprecation-badge highlight-warning inline-block', 'Deprecated'
        @span outlet: 'packageDescription', class: 'package-description', description
        @div outlet: 'packageMessage', class: 'package-message'

      @div class: 'meta', =>
        # @div class: 'meta-user', =>
        #   @a outlet: 'avatarLink', href: "https://atom.io/users/#{owner}", =>
        #     @img outlet: 'avatar', class: 'avatar', src: 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7' # A transparent gif so there is no "broken border"
        #   @a outlet: 'loginLink', class: 'author', href: "https://atom.io/users/#{owner}", owner
        # @div class: 'meta-controls', =>
        #   @div class: 'btn-toolbar', =>
        #     @div outlet: 'updateButtonGroup', class: 'btn-group', =>
        #       @button type: 'button', class: 'btn btn-info icon icon-cloud-download install-button', outlet: 'updateButton', 'Update'
        #     @div outlet: 'installAlternativeButtonGroup', class: 'btn-group', =>
        #       @button type: 'button', class: 'btn btn-info icon icon-cloud-download install-button', outlet: 'installAlternativeButton', 'Install Alternative'
        #     @div outlet: 'installButtonGroup', class: 'btn-group', =>
        #       @button type: 'button', class: 'btn btn-info icon icon-cloud-download install-button', outlet: 'installButton', 'Install'
        #     @div outlet: 'packageActionButtonGroup', class: 'btn-group', =>
        #       @button type: 'button', class: 'btn icon icon-gear settings',             outlet: 'settingsButton', 'Settings'
        #       @button type: 'button', class: 'btn icon icon-trashcan uninstall-button', outlet: 'uninstallButton', 'Uninstall'
        #       @button type: 'button', class: 'btn icon icon-playback-pause enablement', outlet: 'enablementButton', =>
        #         @span class: 'disable-text', 'Disable'
        #       @button type: 'button', class: 'btn status-indicator', tabindex: -1, outlet: 'statusIndicator'

  initialize: (@pack, @packageManager, options) ->
    @disposables = new CompositeDisposable()
