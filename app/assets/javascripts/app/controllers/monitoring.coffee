class Index extends App.ControllerSubContent
  requiredPermission: 'admin.monitoring'
  header: 'Monitoring'
  events:
    'click .js-resetToken': 'resetToken'
    'click .js-select': 'selectAll'
    'click .js-restartDeadJobs': 'restartDeadJobs'

  constructor: ->
    super
    @load()
    @interval(
      =>
        @load()
      35000
    )

  # fetch data, render view
  load: ->
    @startLoading()
    @ajax(
      id:    'health_check'
      type:  'GET'
      url:   "#{@apiPath}/monitoring/health_check"
      success: (data) =>
        @stopLoading()
        return if @data && data.token is @data.token && data.healthy is @data.healthy && data.message is @data.message
        @data = data
        @render()
    )

  render: =>
    @html App.view('monitoring')(
      data: @data
      job_restart_count: @job_restart_count
    )

  resetToken: (e) =>
    e.preventDefault()
    @formDisable(e)
    @ajax(
      id:    'health_check_token'
      type:  'POST'
      url:   "#{@apiPath}/monitoring/token"
      success: (data) =>
        @load()
    )

  restartDeadJobs: (e) =>
    e.preventDefault()
    @ajax(
      id:    'restart_dead_jobs_request'
      type:  'POST'
      url:   "#{@apiPath}/monitoring/restart_dead_jobs"
      success: (data) =>
        @job_restart_count = data.job_restart_count
        @render()
    )

App.Config.set('Monitoring', { prio: 3600, name: 'Monitoring', parent: '#system', target: '#system/monitoring', controller: Index, permission: ['admin.monitoring'] }, 'NavBarAdmin')
