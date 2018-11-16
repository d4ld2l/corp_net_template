class CreateInfo360SourceGithubRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :info360_source_github_repositories do |t|
      t.references :info360_source_github, index: {name: 'info360_source_github_on_github_id'}
      t.string :url
      t.boolean :fork
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
