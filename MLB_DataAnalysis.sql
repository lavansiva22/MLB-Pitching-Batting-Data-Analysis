SELECT *
FROM RaysPitching.LastPitchRays

SELECT *
FROM RaysPitching.RaysPitchingStats

-- Question 1 AVG Pitches Per at Bat Analysis

-- 1a AVG Pitches Per At Bat (LastPitchRays)
SELECT AVG(1.00 * Pitch_number) AS AvgNumofPitchesPerAtBat
FROM RaysPitching.LastPitchRays


-- 1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union
SELECT
	'Home' AS TypeofGame,
	AVG(1.00 * Pitch_number) AS AvgNumofPitchesPerAtBat
FROM RaysPitching.LastPitchRays
WHERE home_team = 'TB'
UNION
SELECT
	'Away' AS TypeofGame,
	AVG(1.00 * Pitch_number) AS AvgNumofPitchesPerAtBat
FROM RaysPitching.LastPitchRays
WHERE away_team = 'TB'
	

-- 1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement 
SELECT
	AVG(Case when batter_position = 'L' then 1.00 * Pitch_number end) AS LeftyatBats,
	AVG(Case when batter_position = 'R' then 1.00 * Pitch_number end) AS RightyatBats
FROM RaysPitching.LastPitchRays


-- 1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By
SELECT DISTINCT
	home_team,
	Pitcher_position,
	AVG(1.00 * Pitch_number) OVER (Partition by home_team, Pitcher_position)
FROM RaysPitching.LastPitchRays
WHERE away_team = 'TB'


-- 1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts (LastPitchRays)
with totalpitchsequence as (
	SELECT DISTINCT
		Pitch_name,
		Pitch_number,
		count(Pitch_name) OVER (Partition by Pitch_name, Pitch_number) AS PitchFrequency
	FROM RaysPitching.LastPitchRays
	where Pitch_number < 11
),
pitchfrequencyrankquery as (
	SELECT
		Pitch_name,
		Pitch_number,
		PitchFrequency,
		rank() OVER (Partition by Pitch_Number order by PitchFrequency desc) AS PitchFrequencyRanking
	FROM totalpitchsequence
)
SELECT *
FROM pitchfrequencyrankquery
WHERE PitchFrequencyRanking < 4


-- 1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)
SELECT 
	RPS.Player,
	AVG(1.00 * Pitch_number) AS AVGPitches
FROM RaysPitching.LastPitchRays LPR
JOIN RaysPitching.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
WHERE IP >= 20
group by RPS.Player
order by AVG(1.00 * Pitch_number) DESC


-- Question 2 Last Pitch Analysis

-- 2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)
SELECT pitch_name, count(*) AS timesthrown
FROM RaysPitching.LastPitchRays
group by pitch_name
order by count(*) DESC


-- 2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)
SELECT
	sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) AS Fastball,
	sum(case when pitch_name NOT in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) AS Offspeed
FROM RaysPitching.LastPitchRays


-- 2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)
SELECT
	100 * sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) / count(*) AS FastballPercent,
	100 * sum(case when pitch_name NOT in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) / count(*) AS OffspeedPercent
FROM RaysPitching.LastPitchRays


-- 2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)
SELECT *
FROM (
	SELECT 
		a.Pos,
		a.pitch_name,
		a.timesthrown,
		RANK() OVER (Partition by a.Pos Order by a.timesthrown DESC) AS PitchRank
	FROM (
		SELECT RPS.Pos, LPR.pitch_name, count(*) AS timesthrown
		FROM RaysPitching.LastPitchRays LPR
		JOIN RaysPitching.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
		group by RPS.Pos, LPR.pitch_name
	) a
) b
WHERE b.PitchRank < 6

-- Question 3 Homerun analysis

-- 3a What pitches have given up the most HRs (LastPitchRays)
SELECT pitch_name, count(*) AS HRs
FROM RaysPitching.LastPitchRays
where events = 'home_run'
group by pitch_name
order by count(*) DESC


-- 3b Show HRs given up by zone and pitch, show top 5 most common
SELECT zone, pitch_name, count(*) AS HRs
FROM RaysPitching.LastPitchRays
where events = 'home_run'
group by zone, pitch_name
order by count(*) DESC
LIMIT 5;


-- 3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher
SELECT RPS.Pos, LPR.balls, LPR.strikes, count(*) AS HRs
FROM RaysPitching.LastPitchRays LPR
JOIN RaysPitching.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
where events = 'home_run'
group by RPS.Pos, LPR.balls, LPR.strikes
order by count(*) DESC


-- 3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)
with hrcountpitchers as (
	SELECT RPS.Player, LPR.balls, LPR.strikes, count(*) AS HRs
	FROM RaysPitching.LastPitchRays LPR
	JOIN RaysPitching.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
	where events = 'home_run' and IP >= 30
	group by RPS.Player, LPR.balls, LPR.strikes
),
hrcountranks as (
	SELECT 
		hcp.Player,
		hcp.balls,
		hcp.strikes,
		hcp.HRs,
		rank() OVER (Partition by Player order by HRs DESC) AS hrrank
	FROM hrcountpitchers AS hcp
)
SELECT ht.Player, ht.balls, ht.strikes, ht.HRs
FROM hrcountranks AS ht
where hrrank = 1

-- Question 4 Shane McClanahan

-- 4a AVG Release speed, spin rate,  strikeouts, most popular zone ONLY USING LastPitchRays
SELECT 
	AVG(release_speed) AS AvgReleaseSpeed,
	AVG(release_spin_rate) AS AvgSpinRate,
	SUM(case when events = 'strikeout' then 1 else 0 end) AS strikeouts,
	MAX(zones.zone) as Zone
FROM RaysPitching.LastPitchRays LPR
join(

	SELECT pitcher, zone, count(*) AS zonenum
	FROM RaysPitching.LastPitchRays LPR
	where player_name = 'McClanahan, Shane'
	group by pitcher, zone
	order by count(*) DESC
	LIMIT 1
	
) zones on zones.pitcher = LPR.pitcher
where player_name = 'McClanahan, Shane'


-- 4b top pitches for each infield position where total pitches are over 5, rank them
SELECT *
FROM (
	SELECT pitch_name, count(*) AS timeshit, 'Third' AS Position
	FROM RaysPitching.LastPitchRays
	WHERE hit_location = 5 and player_name = 'McClanahan, Shane'
	group by pitch_name
	UNION
	SELECT pitch_name, count(*) AS timeshit, 'Short' AS Position
	FROM RaysPitching.LastPitchRays
	WHERE hit_location = 6 and player_name = 'McClanahan, Shane'
	group by pitch_name
	UNION
	SELECT pitch_name, count(*) AS timeshit, 'Second' AS Position
	FROM RaysPitching.LastPitchRays
	WHERE hit_location = 4 and player_name = 'McClanahan, Shane'
	group by pitch_name
	UNION
	SELECT pitch_name, count(*) AS timeshit, 'First' AS Position
	FROM RaysPitching.LastPitchRays
	WHERE hit_location = 3 and player_name = 'McClanahan, Shane'
	group by pitch_name
) a
where timeshit > 4
order by timeshit


-- 4c Show different balls/strikes as well as frequency when someone is on base 
SELECT balls, strikes, count(*) AS frequency
FROM RaysPitching.LastPitchRays
WHERE (on_3b is NOT NULL or on_2b is NOT NULL or on_1b is NOT NULL)
and player_name = 'McClanahan, Shane'
group by balls, strikes
order by count(*) DESC


-- 4d What pitch causes the lowest launch speed
SELECT pitch_name, AVG(1.00 * launch_speed) AS LaunchSpeed
FROM RaysPitching.LastPitchRays
WHERE player_name = 'McClanahan, Shane'
group by pitch_name
order by LaunchSpeed
LIMIT 1
