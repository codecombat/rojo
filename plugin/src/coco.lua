-- from app/init.lua

local serveSession = ServeSession.new({
	apiContext = apiContext,
	openScriptsExternally = sessionOptions.openScriptsExternally,
	twoWaySync = sessionOptions.twoWaySync,
})

serveSession:onPatchApplied(function(patch, unapplied)
	local now = os.time()
	local changes = 0

	for _, set in patch do
		for _ in set do
			changes += 1
		end
	end
	for _, set in unapplied do
		for _ in set do
			changes -= 1
		end
	end

	if changes == 0 then return end

	local old = self.patchInfo:getValue()
	if now - old.timestamp < 2 then
		changes += old.changes
	end

	self.setPatchInfo({
		changes = changes,
		timestamp = now,
	})
end)

--ServeSession.lua contains most of the logic
--Unlike the Plugin, we don't care about when things update,
--rather we are alright just taking a snapshot and serializing it.

-- check ServeSession:__initialSync
-- not sure what root instance ID is, but it's ready with __apiContext:write
-- Reconciler is important, it contains diffs between what we have and what we want
-- applyPatch seems to be what does the actual patching
-- hydrate is just a tree walk over the virtual dom and the actual game, we may
-- not need that at first.

-- diff is where the big logic happens, we would call that between an empty
-- instance map and the root of the level, returns a patch

-- so, get instance ID,
-- calculate the diff between an empty instance map and the root of the level,
-- apply the patch to the empty instance map.
-- later can apply hydration in case we want to re-sync.
-- reify handles constructing a real dom from the virtual dom.

-- API context contains information about the server, such as the server's
-- rootInstanceid. We'll also want this to communicate with our server.
-- rootInstanceId comes from the Rojo server.

--api.rs contains roto_instance_id
-- from referent.rs, the root ID is a random number whic is generated by the server.

-- Plan:

-- 1. Use the reconcilier to calculate the diff between the game and empty
-- calculate a patch
-- Use the ApiContext:write type methods to serialize the diff.
-- print out the serialized diff