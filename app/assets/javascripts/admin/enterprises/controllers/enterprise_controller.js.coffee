angular.module("admin.enterprises")
  .controller "enterpriseCtrl", ($scope, $http, $window, NavigationCheck, enterprise, EnterprisePaymentMethods, EnterpriseShippingMethods, SideMenu, StatusMessage) ->
    $scope.Enterprise = enterprise
    $scope.PaymentMethods = EnterprisePaymentMethods.paymentMethods
    $scope.ShippingMethods = EnterpriseShippingMethods.shippingMethods
    $scope.navClear = NavigationCheck.clear
    $scope.menu = SideMenu
    $scope.newManager = { id: null, email: (t('add_manager')) }
    $scope.StatusMessage = StatusMessage

    $scope.$watch 'enterprise_form.$dirty', (newValue) ->
      StatusMessage.display 'notice', t('admin.unsaved_changes') if newValue

    $scope.setFormDirty = ->
      $scope.$apply ->
        $scope.enterprise_form.$setDirty()

    $scope.cancel = (destination) ->
      $window.location = destination

    $scope.submit = ->
      $scope.navClear()
      enterprise_form.submit()

    # Provide a callback for generating warning messages displayed before leaving the page. This is passed in
    # from a directive "nav-check" in the page - if we pass it here it will be called in the test suite,
    # and on all new uses of this contoller, and we might not want that.
    enterpriseNavCallback = ->
      if $scope.enterprise_form != undefined && $scope.enterprise_form.$dirty
        t('admin.unsaved_confirm_leave')

    # Register the NavigationCheck callback
    NavigationCheck.register(enterpriseNavCallback)

    $scope.removeManager = (manager) ->
      if manager.id?
        if manager.id == $scope.Enterprise.owner.id or manager.id == parseInt($scope.receivesNotifications)
          return
        for i, user of $scope.Enterprise.users when user.id == manager.id
          $scope.Enterprise.users.splice i, 1
          $scope.enterprise_form?.$setDirty()

    $scope.addManager = (manager) ->
      if manager.id? and angular.isNumber(manager.id) and manager.email?
        manager =
          id: manager.id
          email: manager.email
          confirmed: manager.confirmed
        if (user for user in $scope.Enterprise.users when user.id == manager.id).length == 0
          $scope.Enterprise.users.push manager
          $scope.enterprise_form?.$setDirty()
        else
          alert ("#{manager.email}" + " " + t("is_already_manager"))

    $scope.inviteManager = ->
      $scope.invite_errors = $scope.invite_success = null
      email = $scope.newUser

      $http.post("/admin/manager_invitations", {email: email, enterprise_id: $scope.Enterprise.id}).success (data)->
          $scope.addManager({id: data.user, email: email})
          $scope.invite_success = t('user_invited', email: email)
        .error (data) ->
          $scope.invite_errors = data.errors

    $scope.resetModal = ->
      $scope.newUser = $scope.invite_errors = $scope.invite_success = null
