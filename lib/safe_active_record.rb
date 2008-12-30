module SafeActiveRecord

  def safe_attributes(*args, &block)
    #取出string与text字段,并转成相应的符号
    string_column = fetch_string_or_text
    
    #找出所有要转义的字段
    if args.empty?
      safe_attributes = string_column  #不传字段,转义所有属性
    elsif args.first.is_a?(Hash)
      safe_attributes = string_column - wrap_array(args.first[:except])#传入hash的话,把指定的给减掉
    elsif args.is_a?(Array)
      safe_attributes = args
    end
    
    #检查有否有不正确的输入字段
    santize(safe_attributes, string_column)
    
    # 重命名方法
    safe_attributes.each do |attribute|#重写一些方法
      define_method attribute do
        attribute_before_cast = h(send(:read_attribute,attribute))
        block ? block.call(attribute_before_cast) :attribute_before_cast
      end
    end
  end

  # 清洁参数,指定的参数不存在,抛出异常
  def santize(attributes, string_column)
    unknow_column = attributes - string_column
    raise "指定的安全字段(#{unknow_column.join(' ')})不存在, 或者不为string 与 text 的值" unless  unknow_column.blank?
  end
  
  #取出string 与 text的字段
  def fetch_string_or_text
    columns.select { |column| [:string, :text].include?(column.type) }.map {|column| column.name.intern}
  end
  
  #如果参数不是数组,就加到数组里面,如果是数组,就不管它
  def wrap_array(array)
    !array.is_a?(Array) ? [array] : array
  end
end


def h(string)
  CGI.escapeHTML(string)
end