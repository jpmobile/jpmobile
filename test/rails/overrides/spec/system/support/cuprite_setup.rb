require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    **{
      window_size: [1200, 800],
      browser_options: {},
      inspector: true,
    },
  )
end

Capybara.default_driver = Capybara.javascript_driver = :cuprite
