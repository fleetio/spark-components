module Components
  module ComponentHelper
    def component(name, attrs = nil, &block)
      comp = "#{name}_component".classify.constantize.new(self, attrs, &block)
      comp.pre_render
      comp.render
    end
  end
end
