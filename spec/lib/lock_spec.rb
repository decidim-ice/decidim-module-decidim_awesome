# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe Lock do
    let(:organization) { resource.organization }
    let(:resource) { create(:dummy_component) }
    let(:lock) { described_class.new(organization) }

    describe "#get!" do
      it "acquires the lock" do
        lock.get!(resource)
        expect(lock.locked?(resource)).to be true
      end
    end

    describe "#release!" do
      it "releases the lock" do
        lock.get!(resource)
        lock.release!(resource)
        expect(lock.locked?(resource)).to be false
      end
    end

    context "when lock already exists" do
      let(:another_lock) { described_class.new(organization) }

      before do
        another_lock.get!(resource)
      end

      describe "#get!" do
        it "lock is still valid" do
          lock.get!(resource)
          expect(lock.locked?(resource)).to be true
        end
      end

      describe "#release!" do
        it "releases the lock" do
          lock.release!(resource)
          expect(lock.locked?(resource)).to be false
          expect(another_lock.locked?(resource)).to be false
        end
      end
    end

    context "when lock is expired" do
      let(:lock_time) { ::Decidim::DecidimAwesome.lock_time + 1.minute }

      before do
        lock.get!(resource)
        travel(lock_time)
      end

      describe "#locked?" do
        it "releases the lock" do
          expect(lock.locked?(resource)).to be false
        end
      end

      context "when lock time is passed as a paramater" do
        let(:lock_time) { ::Decidim::DecidimAwesome.lock_time - 1.minute }
        let(:lock) { described_class.new(organization, lock_time: lock_time - 30.seconds) }

        describe "#locked?" do
          it "releases the lock" do
            expect(lock.locked?(resource)).to be false
          end
        end
      end
    end
  end
end
