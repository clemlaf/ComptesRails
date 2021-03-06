class EntryRecord < ApplicationRecord
  self.abstract_class=true


  def self.build_from_form(idp,attrs)
    id=idp[:id]
    if attrs.has_key?(:pr)
      pr=attrs[:pr]
      if pr.respond_to?(:sub)
        pr=pr.sub(",",".")
      end
      prf=pr.to_f
      attrs[:pr]=(100.0*prf+(prf>0?0.5:-0.5)).to_i
    end
    if id=="new" or not self.exists?(id)
      nentry=self.create(attrs)
    else
      nentry=self.find(id)
      nentry.update(attrs)
    end
    puts nentry.inspect
    puts nentry.errors.full_messages
    return nentry
  end
end
