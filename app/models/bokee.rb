# frozen_string_literal: true

# Bokee represents an entity that books Venues. It has many Orders
# and is associated with the Venues it books through those orders.
class Bokee < ApplicationRecord
  has_many :orders

  validates :full_name, presence: { message: 'Jméno nemůže být prázdné' }
  validates :phone_number, presence: { message: 'Tel. číslo nemůže být prázdné.' }
  validates :phone_number,
            format: { with: /\A\+?(\d{1,3})?[-. ]?\(?\d{1,3}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}[-. ]?\d{1,9}\z/,
                      message: 'Zadejte své telefonní číslo ve standardním mezinárodním formátu, s možným předčíslím (+), kódem oblasti a číslem. Oddělte části čísla mezerami. Například: +420 123 456 789.' }
  validates :email, presence: { message: 'Email nemůže být prázdné.' }
  validates :email,
            format: { with: %r{\A[a-zA-Z0-9+_.~\-!#$%&'=/^`{}|]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z},
                      message: "Email musí být složen z těchto znaků: velká písmena (A-Z), malá písmena (a-z), číslice (0-9), plus (+), pomlčka (-), podtržítko (_), vlnovka (~), vykřičník (!), mřížka (#), dolar ($), procento (%), ampersand (&), jednoduchý uvozovky ('), tečka (.), lomítko (/), rovnítko (=), stříška (^), zpětný apostrof (`), levá složená závorka ({), pravá složená závorka (}), a svislá čára (|)." }
end
