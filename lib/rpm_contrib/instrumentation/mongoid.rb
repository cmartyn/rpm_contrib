if defined?(::Mongoid) && !NewRelic::Control.instance['disable_mongodb']

  module Mongoid #:nodoc:
    module Collection

      #adding call to super
      class << self
        alias :old_included :included

        def included(model)
          old_included(model)
          super
        end
      end
    end
  end

  module RPMContrib::Instrumentation

    module Mongoid
      def included(model)
        model.class_eval do
          (%w(find find_one map_reduce) + Collections::Operations::PROXIED - ['<<']).uniq.each do |method|
            add_method_tracer method, "MongoDB/\#{@klass}##{method}"
          end
        end
        super
      end
    end
    ::Mongoid::Document.extend(RPMContrib::Instrumentation::Mongoid)
  end
end
