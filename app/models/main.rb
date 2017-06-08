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
    cps=self.class.to_iarr(@cpS_ids)
    cpd=self.class.to_iarr(@cpD_ids)
    cats=self.class.to_iarr(@category_ids)
    moys=self.class.to_iarr(@moyen_ids)
    args={}
    args[:cpS]=cps unless cps.empty?
    args[:cpD]=cpd unless cpd.empty?
    args[:category]=cats unless cats.empty?
    args[:moyen]=moys unless moys.empty?
    args[:com]=@com unless (@com==nil or @com.to_s.length<1)
    return args
  end
  def getDate1()
    return @date1.to_date if @date1.respond_to?(:to_date) and not @date1.is_a?(String)
    Date.strptime(@date1, I18n.t('date.formats.default')) rescue nil
  end
  def getDate2()
    return @date2.to_date if @date2.respond_to?(:to_date) and not @date2.is_a?(String)
    Date.strptime(@date2, I18n.t('date.formats.default')) rescue nil
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
