# encoding: utf-8
module Crumby

  class Breadcrumbs
    attr_reader :items

    def initialize
      @items = []
    end

    def add(*args)
      options = args.extract_options!
      if args.empty?
        raise ArgumentError, "Need arguments."
      elsif args.count == 1
        value = args.first
        if value.is_a? String
          label = value
        elsif value.is_a? Symbol
          label = value.to_s.humanize
          route = value
        elsif value.respond_to? :model_name
          label = value.model_name.human
          route = value
        elsif value.kind_of? Array
          if value.last.respond_to? :model_name
            label = value.last.model_name.human
          else
            label = value.last.to_s.humanize
          end
          route = value
        else
          label = value.to_s.humanize
        end
      else
        label = args.first
        route = args.second
      end

      item = Breadcrumb.new(label, route, options)
      @items << item
      item
    end

  end

end