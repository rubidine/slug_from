# Copyright (c) 2009 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module SlugFrom
  def self.included kls
    kls.send :extend, ClassMethods
  end

  module ClassMethods
    def slug_from field, options = {}
      include InstanceMethods
      write_inheritable_attribute(:slug_from_field, field.to_s)
      options.symbolize_keys!
      callback = options.delete(:callback) || :before_validation
      write_inheritable_attribute(:slug_options, options)
      send callback, :set_slug
    end
  end

  module InstanceMethods
    def to_param
      options = self.class.read_inheritable_attribute(:slug_options)
      slug_field = options[:slug_field] || :slug
      send(slug_field)
    end

    private
    def set_slug
      field = self.class.read_inheritable_attribute(:slug_from_field)
      options = self.class.read_inheritable_attribute(:slug_options)
      return unless changes[field]
      slug_field = options[:slug_field] || :slug
      writer = options[:writer] || "#{slug_field}="
      computer = options[:computer] || :compute_slug
      value = send(field)
      slug = send(computer, value)
      send(writer, slug)
    end

    def compute_slug val
      val.to_s.downcase.gsub(/[^\w\s]/, '').gsub(/\s+/, '-')
    end
  end
end
