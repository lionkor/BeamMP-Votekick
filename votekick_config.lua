-- Percentage of people needed to vote someone out.
-- The person being voted out counts towards the percentage
-- as an automatic NO vote.
-- Keep in mind that for a vote to start, more than 2 people have
-- to be in the server.
-- default: 75 (%)

votekick_percent = 75

-- Command to start a votekick.
-- Usage will be:
--      <command> <username>
-- Example:
--      /votekick LionKor
-- It's recommended for this to start with a `/`. It HAS to be in " quotes.
-- default: "/votekick"

votekick_command = "/votekick"

-- Command used to vote YES for a votekick
-- Usage will be:
--      <command>
-- Example: 
--      /v yes
-- It's recommended for this to start with a `/`.
-- default: "/v yes"

votekick_yes = "/v yes"

-- Command used to vote NO for a votekick
-- Usage will be:
--      <command>
-- Example: 
--      /v no
-- It's recommended for this to start with a `/`.
-- default: "/v no"

votekick_no = "/v no"

-- Timeout for a kick.
-- After this many minutes, new votekicks can be started and YES / NO votes
-- are no longer accepted. A timed out votekick is always repeatable (see next
-- section).
-- default: 5 (minutes)

votekick_timeout_minutes = 5

-- Repeatable votekick.
-- If this is set to `true`, a failed votekick may be reattempted immediately
-- by the same person.
-- This means that someone can try votekicking the same person repeatedly.
-- If set to `false`, a different votekick has to happen in between, or someone
-- else has to reattempt the votekick. After a timeout a vote can be reattempted
-- regardless of this setting.
-- default: false

votekick_repeatable = false

