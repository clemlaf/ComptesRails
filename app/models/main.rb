class MainForm
  include ActiveModel::Model

  attr_accessor(:cpS_ids, :cpD_ids, :date1, :date2,
                :category_ids, :moyen_ids, :com, :poS, :type, :page, :nb)

  @@defa={cpS_ids:nil,
    cpD_ids:nil,
    date1:nil,
    date2:nil,
    category_ids:nil,
    type:1,
    com:nil,
    poS:nil,
    moyen_ids:nil,
    nb:15,
    page:0
  }
  def initialize attributes = @@defa
    super attributes
  end

  def to_hash()
    puts @cpS_ids
    puts @cpS_ids.inspect
    args={}
    args[:cpS]=cpS_ids unless cpS_ids.empty?
    args[:cpD]=cpD_ids unless cpD_ids.empty?
    args[:category]=category_ids unless category_ids.empty?
    args[:moyen]=moyen_ids unless moyen_ids.empty?
    args[:com]=com unless com.empty?
    return args
  end
  def to_type
    cpS_ids=self.class.to_iarr cpS_ids
    cpD_ids=self.class.to_iarr cpD_ids
    category_ids=self.class.to_iarr category_ids
    moyens_ids=self.class.to_iarr moyens_ids
    if date1.respond_to?(:to_date) and not date1.is_a?(String)
      date1=date1.to_date
    else
      date1=Date.strptime(date1, I18n.t('date.formats.default')) rescue nil
    end
    if date2.respond_to?(:to_date) and not date2.is_a?(String)
      date2=date2.to_date
    else
      date2=Date.strptime(date2, I18n.t('date.formats.default')) rescue nil
    end
    com=com.to_s
    nb=nb.to_i
    type=type.to_i
    page=page.to_i
    poS=poS.to_s
  end

  def persisted?
    false
  end
  private
  def self.to_iarr(arr)
    narr=[]
    return narr if arr==nil
    arr.each do |c|
      if c.kind_of?(String) and c.to_str.length>0
        narr.push(c.to_i)
      elsif c.kind_of?(Integer)
        narr.push(c.to_i)
      end
    end
    narr
  end
end
