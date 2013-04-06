require "rulers/version"
require "rulers/array"
require "rulers/routing"

module Rulers
 class Application
    attr_accessor :static_pages
    def initialize
      @static_pages = Hash.new
      @static_pages['/'] = File.read("app/public/index.html")
      @static_pages['404'] = File.read("app/public/500.html")
      @static_pages['500'] = File.read("app/public/404.html")
    end

    def call(env)

      if env['PATH_INFO'] == '/favicon.ico'
            return [404,
              {'Content-Type' => 'text/html'}, []]
      elsif @static_pages.has_key?(env['PATH_INFO'])
            return [200,
              {'Content-Type' => 'text/html'}, [
                @static_pages[env['PATH_INFO']]
                ]]
      end

      begin
        klass, act = get_controller_and_action(env)
        controller = klass.new(env)
      rescue
       return [404, {'Content-Type' => 'text/html'},
        [@static_pages['404']]]
      end

      begin
        text = controller.send(act)
      rescue
       return [500, {'Content-Type' => 'text/html'},
        [@static_pages['500']]]
      end

      [200, {'Content-Type' => 'text/html'},
        [text]]
    end
  end

  class Controller
    def initialize(env)
      @env = env end
    def env
      @env
    end
  end
end
