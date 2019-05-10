window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function CookieSettings () { }

  CookieSettings.prototype.start = function ($module) {
    this.$module = $module[0]

    this.$module.submitSettingsForm = this.submitSettingsForm.bind(this)

    this.$module.addEventListener('submit', this.$module.submitSettingsForm)

    this.setInitialFormValues()
  }

  CookieSettings.prototype.setInitialFormValues = function () {
    var currentConsentCookie = window.GOVUK.cookie('cookie_policy')

    if (currentConsentCookie) {
      var currentConsentCookieJSON = JSON.parse(currentConsentCookie)

      // We don't need the essential value as this cannot be changed by the user
      delete currentConsentCookieJSON["essential"]

      for (var cookieType in currentConsentCookieJSON) {
        if (currentConsentCookieJSON[cookieType]) {
          var radioButton = document.querySelector('input[name=cookies-' + cookieType + '][value=on]')
          radioButton.checked = true
        } else {
          var radioButton = document.querySelector('input[name=cookies-' + cookieType + '][value=off]')
          radioButton.checked = true
        }
      }
    } else {
      window.GOVUK.setDefaultConsentCookie()
      this.setInitialFormValues()
    }
  }

  CookieSettings.prototype.submitSettingsForm = function (event) {
    event.preventDefault()

    var formInputs = event.target.getElementsByTagName("input");
    var options = {}

    for ( var i = 0; i < formInputs.length; i++ ) {
      var input = formInputs[i]
      if (input.checked) {
        var name = input.name.replace('cookies-', '')
        var value = input.value === "on" ? true : false

        options[name] = value
      }
    }

    window.GOVUK.setConsentCookie(options)
  }

  Modules.CookieSettings = CookieSettings
})(window.GOVUK.Modules)
