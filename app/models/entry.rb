class Entry < EntryRecord
  belongs_to :cpS, class_name: "Compte", foreign_key: :cpS_id
  belongs_to :cpD, class_name: "Compte", foreign_key: :cpD_id, optional: :true
  belongs_to :moyen, optional: :true
  belongs_to :category, optional: :true

  @@param_list = [:date, :cpS_id, :cpD_id, :com, :pr, :moyen_id, :category_id, :poS]


  def reverse(cptab)
    cptab.each do |cpid|
      if cpS_id == cpid
        break
      end
      if self.cpD_id == cpid and self.cpS_id !=cpid
        tmp=self.cpD_id
        self.cpD_id=self.cpS_id
        self.cpS_id=tmp
        self.pr=-self.pr
        tmp=self.poD
        self.poD=self.poS
        self.poS=tmp
        break
      end
    end
    self
  end
  def issym?(cptab,cptabD)
    out=false
    out|=(cptab.include? self.cpS_id and cptab.include? self.cpD_id) if cptab.respond_to?(:include?)
    out|=(cptabD.include? self.cpS_id and cptabD.include? self.cpD_id) if cptabD.respond_to?(:include?)
    puts out
    out
  end

end
