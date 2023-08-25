# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Patch::RedisCacheStore, :use_clean_rails_redis_caching, feature_category: :scalability do
  let(:cache) { Rails.cache }

  before do
    cache.write('x', 1)
    cache.write('y', 2)
    cache.write('z', 3)

    cache.write('{user1}:x', 1)
    cache.write('{user1}:y', 2)
    cache.write('{user1}:z', 3)
  end

  describe '#read_multi_mget' do
    shared_examples 'reading using cache stores' do
      it 'gets multiple cross-slot keys' do
        expect(
          Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
            # fetch_multi requires a block and we have to specifically test it
            # as it is used in the Gitlab project
            cache.fetch_multi('x', 'y', 'z') { |key| key }
          end
        ).to eq({ 'x' => 1, 'y' => 2, 'z' => 3 })
      end

      it 'gets multiple keys' do
        expect(
          cache.fetch_multi('{user1}:x', '{user1}:y', '{user1}:z') { |key| key }
        ).to eq({ '{user1}:x' => 1, '{user1}:y' => 2, '{user1}:z' => 3 })
      end

      context 'when reading large amount of keys' do
        it 'batches get into pipelines of 100' do
          cache.redis.with do |redis|
            normal_cluster = !redis.is_a?(Gitlab::Redis::MultiStore) && Gitlab::Redis::ClusterUtil.cluster?(redis)
            multistore_cluster = redis.is_a?(Gitlab::Redis::MultiStore) &&
              ::Gitlab::Redis::ClusterUtil.cluster?(redis.default_store)

            if normal_cluster || multistore_cluster
              expect(redis).to receive(:pipelined).at_least(2).and_call_original
            else
              expect(redis).to receive(:mget).and_call_original
            end
          end

          Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
            cache.read_multi(*Array.new(101) { |i| i })
          end
        end
      end
    end

    context 'when cache is Rails.cache' do
      let(:cache) { Rails.cache }

      context 'when reading using secondary store as default' do
        before do
          stub_feature_flags(use_primary_store_as_default_for_cache: false)
        end

        it_behaves_like 'reading using cache stores'
      end

      it_behaves_like 'reading using cache stores'
    end

    context 'when cache is feature flag cache store' do
      let(:cache) { Gitlab::Redis::FeatureFlag.cache_store }

      it_behaves_like 'reading using cache stores'
    end

    context 'when cache is repository cache store' do
      let(:cache) { Gitlab::Redis::RepositoryCache.cache_store }

      it_behaves_like 'reading using cache stores'
    end
  end

  describe '#delete_multi_entries' do
    shared_examples 'deleting using cache stores' do
      it 'deletes multiple cross-slot keys' do
        expect(Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
          cache.delete_multi(%w[x y z])
        end).to eq(3)
      end

      it 'deletes multiple keys' do
        expect(
          cache.delete_multi(%w[{user1}:x {user1}:y {user1}:z])
        ).to eq(3)
      end

      context 'when deleting large amount of keys' do
        before do
          200.times { |i| cache.write(i, i) }
        end

        it 'calls pipeline multiple times' do
          cache.redis.with do |redis|
            # no expectation on number of times as it could vary depending on cluster size
            # if the Redis is a Redis Cluster
            if Gitlab::Redis::ClusterUtil.cluster?(redis)
              expect(redis).to receive(:pipelined).at_least(2).and_call_original
            else
              expect(redis).to receive(:del).and_call_original
            end
          end

          expect(
            Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
              cache.delete_multi(Array(0..199))
            end
          ).to eq(200)
        end
      end
    end

    context 'when cache is Rails.cache' do
      let(:cache) { Rails.cache }

      it_behaves_like 'deleting using cache stores'
    end

    context 'when cache is feature flag cache store' do
      let(:cache) { Gitlab::Redis::FeatureFlag.cache_store }

      it_behaves_like 'deleting using cache stores'
    end

    context 'when cache is repository cache store' do
      let(:cache) { Gitlab::Redis::RepositoryCache.cache_store }

      it_behaves_like 'deleting using cache stores'
    end
  end
end
