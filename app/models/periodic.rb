class Periodic < ApplicationRecord
  belongs_to :cpS, class_name: "Compte", foreign_key: :cpS_id
  belongs_to :cpD, class_name: "Compte", foreign_key: :cpD_id, optional: :true
  belongs_to :moyen, optional: :true
  belongs_to :category, optional: :true
  def nextdate
    self.lastdate+ self.days.days + self.months.months
  end
  def self.build_from_form(idp,attrs)
    id=idp[:id]
    if attrs.has_key?(:pr)
      prf=attrs[:pr].to_f
      attrs[:pr]=(100.0*prf+(prf>0?0.5:-0.5)).to_i
    end
    if id=="new" or not Periodic.exists?(id)
      nentry=Periodic.create(attrs)
    else
      nentry=Periodic.find(id)
      nentry.update(attrs)
    end
    puts nentry.inspect
    puts nentry.errors.full_messages
    return nentry
  end
  def self.make_all_entries()
    Periodic.all.each do |period|
      period.make_entries
    end
  end
  def make_entries()
    date=Time.now+7.days
    while nextdate < date do
      Entry.create(
        date: nextdate,
        cpS: cpS,
        cpD: cpD,
        moyen: moyen,
        category: category,
        com: com,
        pr: pr
      )
      update(lastdate:nextdate)
    end
  end
end
