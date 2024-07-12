# frozen_string_literal: true

# Bulk order form model is created for validations of bulk order form.
# Validates every field including the presence of at least one filter.
class BulkOrderForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :city, :min_capacity, :phone_number
  attr_reader :filter_ids

  # validates :full_name, presence: { message: 'Jméno nemůže být prázdné' }
  # validates :phone_number, presence: { message: 'Tel. číslo nemůže být prázdné.' }
  # validates :phone_number,
  #           format: { with: /\A\+?(\d{1,3})?[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9}\z/,
  #                     message: 'Zadejte své telefonní číslo ve standardním mezinárodním formátu, s možným předčíslím (+), kódem oblasti a číslem. Oddělte části čísla mezerami. Například: +420 123 456 789.' }
  # validates :email, presence: { message: 'Email nemůže být prázdné.' }
  # validates :email,
  #           format: { with: %r{\A[a-zA-Z0-9+_.~\-!#$%&'=/^`{}|]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z},
  #                     message: "Email musí být složen z těchto znaků: velká písmena (A-Z), malá písmena (a-z), číslice (0-9), plus (+), pomlčka (-), podtržítko (_), vlnovka (~), vykřičník (!), mřížka (#), dolar ($), procento (%), ampersand (&), jednoduchý uvozovky ('), tečka (.), lomítko (/), rovnítko (=), stříška (^), zpětný apostrof (`), levá složená závorka ({), pravá složená závorka (}), a svislá čára (|)." }

  validates :min_capacity, numericality: { only_integer: true, greater_than: 0 },
                           presence: { message: 'Prosím vyplňte minimální kapacitu' }
end
