class AddTagsToSubmissionsAndUsers < ActiveRecord::Migration
  def change
    add_column :submissions, :tags, :string, array: true, default: '{}'
    add_index  :submissions, :tags, using: 'gin'

    add_column :users, :tags, :string, array: true, default: '{}'
    add_index  :users, :tags, using: 'gin'

    reversible do |direction|
      direction.up do
        {
          trogdor: %w(ibowen@enova.com dkaplan@enova.com jswartzendruber@enova.com spatel1@enova.com npadilla@enova.com ssims@enova.com bsiddhisena@enova.com),
          rumblers: %w(rustam@enova.com sortiz@enova.com zgallup@enova.com jmurphy1@enova.com),
          venture: %w(jhou1@enova.com mkumar@enova.com pnallamala@enova.com rlabok@enova.com jgarguilo@enova.com ywong@envoa.com pschroff@enova.com zgallup@enova.com),
          squeaks: %w(apatel@enova.com vbhat@enova.com kperez@enova.com),
          trolls: %w(cphillips1@enova.com kjavvaji@enova.com gevans@enova.com tanderson3@enova.com psolomon@enova.com),
          knights: %w(mmcdermott@enova.com pchengalasetty@cashnetusa.com egomez@enova.com gkongkaeow@enova.com smittapalli@enova.com sastaputhra@enova.com),
          henchmen: %w(nshah@enova.com cgavrilescu@enova.com skulkarni@enova.com fnazeer@enova.com rnubel@enova.com cwise@enova.com),
          raven: %w(czoppa@enova.com hdombrovskaya@enova.com kglowacz@enova.com rlee@enova.com pdhiman@enova.com nbhardwaj@enova.com),
          ateam: %w(dhavlicek@enova.com kthati@enova.com rmaheshwari@enova.com gjanarthanan@enova.com eedlinger@enova.com esambo@enova.com rsanchez@enova.com ksoifer@enova.com),
          shodan: %w(bsubramanian@enova.com bthomas@enova.com jmiller@enova.com akumar1@enova.com abondzic@enova.com),
          noobs: %w(icundiff@enova.com mguldur@enova.com cmwesigwa@enova.com),
          incredibles: %w(dpollak@enova.com hkotecha@enova.com smanam@enova.com whan@enova.com yfayad@enova.com aabbineni@enova.com),
        }.each do |tag, emails|
          User.where(email: emails).update_all tags: ['rnd', tag]
        end

        User.active.untagged.update_all tags: ['rnd']

        User.tagged.each do |user|
          user.submissions.update_all tags: user.tags
        end
      end
    end
  end
end
