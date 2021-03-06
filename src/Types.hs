{-# LANGUAGE ScopedTypeVariables, GADTs #-}

module Types where

import Data.Maybe (catMaybes)
import Data.SBV

import Beethoven
import Pitch
import Interval
import Motion

pitchPairOpi :: PitchPair -> Opi
pitchPairOpi (a , b) =
  let n = b - a
  in if n > 12 then n `mod` 12 else n

data IntervalSet where
  ConsonantInterval :: IntervalSet
  deriving Show

intervalSet :: IntervalSet -> [Opi]
intervalSet ConsonantInterval =
  [0,  -- perfect unison
   3,  -- minor third
   4,  -- major third
   7,  -- perfect fifth
   8,  -- minor sixth
   9,  -- major sixth
   12] -- perfect octave

data IntervalConstraint where
  IntervalInSet :: IntervalSet -> IntervalConstraint
  deriving Show

data Error where
  IntervalConstraintError :: IntervalConstraint -> Error
  deriving Show

firstSpecies :: IntervalConstraint
firstSpecies = IntervalInSet ConsonantInterval

checkInterval2 :: IntervalConstraint -> Opi -> Maybe Error
checkInterval2 c@(IntervalInSet s) i = let x = intervalSet s in
  if isConsonant i then Nothing else Just (IntervalConstraintError c)

scarlatti :: [PitchPair]
scarlatti =
  [(d 5 , ab 5) ,
   (c 5 , a 5) ,
   (b 4 , b 5) ,
   (a 4 , c 6) ,
   (b 4 , d 6) ,
   (c 5 , e 6) ,
   (d 5 , f 6) ,
   (e 4 , ab 5) ,
   (d 5 , a 5) ,
   (c 5 , e 5) ,
   (d 5 , d 6) ,
   (e 5 , c 6) ,
   (d 5 , d 6) ,
   (e 5 , ab 5) ,
   (e 4 , b 5) ,
   (a 4 , a 5) ]

test = catMaybes (map (checkInterval2 firstSpecies . pitchPairOpi) scarlatti)

testi :: [Bool]
testi = map checkInterval beethoven146

testm :: [Bool]
testm = checkMotion beethoven146

tests :: IO SatResult
tests = sat $ do
  let cf = map literal [c 6, e 6]
  cp1 <- free "0_1" :: Symbolic SInt8
  let cp = [literal (g 5), cp1]
  let music = zip cp cf
  solve $ checkMotion music

t :: IO ()
t = do
  res <- tests
  let x = getModelValue "0_1" res :: Maybe Int8
  putStrLn (show x)  

