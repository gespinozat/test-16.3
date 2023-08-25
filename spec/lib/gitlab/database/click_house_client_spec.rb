# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ClickHouse::Client', feature_category: :database do
  context 'when click_house spec tag is not added' do
    it 'does not have any ClickHouse databases configured' do
      databases = ClickHouse::Client.configuration.databases

      expect(databases).to be_empty
    end
  end

  describe 'when click_house spec tag is added', :click_house do
    it 'has a ClickHouse database configured' do
      databases = ClickHouse::Client.configuration.databases

      expect(databases).not_to be_empty
    end

    it 'does not return data via `execute` method' do
      result = ClickHouse::Client.execute("SELECT 1 AS value", :main)

      # does not return data, just true if successful. Otherwise error.
      expect(result).to eq(true)
    end

    describe 'data manipulation' do
      describe 'inserting' do
        let_it_be(:group) { create(:group) }
        let_it_be(:project) { create(:project) }

        let_it_be(:author1) { create(:user).tap { |u| project.add_developer(u) } }
        let_it_be(:author2) { create(:user).tap { |u| project.add_developer(u) } }

        let_it_be(:issue1) { create(:issue, project: project) }
        let_it_be(:issue2) { create(:issue, project: project) }
        let_it_be(:merge_request) { create(:merge_request, source_project: project) }

        let_it_be(:event1) { create(:event, :created, target: issue1, author: author1) }
        let_it_be(:event2) { create(:event, :closed, target: issue2, author: author2) }
        let_it_be(:event3) { create(:event, :merged, target: merge_request, author: author1) }

        let(:events) { [event1, event2, event3] }

        def format_row(event)
          path = event.project.reload.project_namespace.traversal_ids.join('/')

          action = Event.actions[event.action]
          [
            event.id,
            "'#{path}/'",
            event.author_id,
            event.target_id,
            "'#{event.target_type}'",
            action,
            event.created_at.to_f,
            event.updated_at.to_f
          ].join(',')
        end

        describe 'RSpec hooks' do
          it 'ensures that tables are empty' do
            results = ClickHouse::Client.select('SELECT * FROM events', :main)
            expect(results).to be_empty
          end
        end

        it 'inserts and modifies data' do
          insert_query = <<~SQL
          INSERT INTO events
          (id, path, author_id, target_id, target_type, action, created_at, updated_at)
          VALUES
          (#{format_row(event1)}),
          (#{format_row(event2)}),
          (#{format_row(event3)})
          SQL

          ClickHouse::Client.execute(insert_query, :main)

          results = ClickHouse::Client.select('SELECT * FROM events ORDER BY id', :main)
          expect(results.size).to eq(3)

          last = results.last
          expect(last).to match(a_hash_including(
            'id' => event3.id,
            'author_id' => event3.author_id,
            'created_at' => be_within(0.05).of(event3.created_at),
            'target_type' => event3.target_type
          ))

          ClickHouse::Client.execute("DELETE FROM events WHERE id = #{event3.id}", :main)

          results = ClickHouse::Client.select("SELECT * FROM events WHERE id = #{event3.id}", :main)
          expect(results).to be_empty
        end
      end
    end
  end
end
