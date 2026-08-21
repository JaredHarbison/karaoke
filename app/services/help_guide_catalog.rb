# frozen_string_literal: true

# Catalogs repository-backed, role-aware help guides.
class HelpGuideCatalog
  GUIDE_DIRECTORY = Rails.root.join('docs', 'help')
  GUIDE_METADATA = {
    'queue-basics' => {
      title: 'Using the karaoke queue',
      summary: 'A quick overview of adding songs and following queue status.',
      audience: :all,
      status: :available
    },
    'recurring-events' => {
      title: 'Creating and editing recurring events',
      summary: 'Planned guide for event series and one-off occurrence changes.',
      audience: :venue_operator,
      status: :planned
    },
    'temporary-hosting' => {
      title: 'Delegating temporary hosting',
      summary: 'Planned guide for time-limited event host authority.',
      audience: :venue_operator,
      status: :planned
    },
    'theme-approval' => {
      title: 'Handling theme approval',
      summary: 'Planned guide for reviewing songs that need theme decisions.',
      audience: :venue_operator,
      status: :planned
    },
    'presence-codes' => {
      title: 'Regenerating event access and presence codes',
      summary: 'Planned guide for permanent venue QR and expiring event access.',
      audience: :venue_operator,
      status: :planned
    },
    'fair-queue-overrides' => {
      title: 'Overriding fair queue behavior',
      summary: 'Planned guide for host-visible queue exceptions and audit notes.',
      audience: :venue_operator,
      status: :planned
    }
  }.freeze

  def self.for(user)
    GUIDE_METADATA.filter_map do |slug, metadata|
      next unless visible_to?(metadata[:audience], user)

      metadata.merge(slug: slug, body: GUIDE_DIRECTORY.join("#{slug}.md").read)
    end
  end

  def self.visible_to?(audience, user)
    return false unless user
    return true if audience == :all

    audience == :venue_operator && user.venue_operator?
  end
end
