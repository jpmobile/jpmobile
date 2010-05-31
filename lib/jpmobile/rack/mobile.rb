class Jpmobile::Rack::Mobile
  def initialize(app, options = {})
    @app     = app
    @options = options.dup.clone
  end

  def call(env)
    env = env.clone
    env['rack.jpmobile'] = carrier(env)

    @app.call(env)
  end

  def carrier(env)
    ::Jpmobile::Mobile.carriers.each do |const|
      c = ::Jpmobile::Mobile.const_get(const)
      return c.new(env) if c::USER_AGENT_REGEXP && env['HTTP_USER_AGENT'] =~ c::USER_AGENT_REGEXP
    end

    nil
  end
end
