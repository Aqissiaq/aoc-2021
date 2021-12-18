import Data.Char
import Data.Maybe

data Snum = Lit Int | Pair Snum Snum
  deriving(Show)

-- I can't believe I need this...
fst3 (x,_,_) = x

main :: IO ()
main = do input <- getContents
          let snums = map parse (lines input)
          -- part 1
          print . magnitude $  foldl1 (\x y -> reduce $ x `sAdd` y) snums
          -- part 2
          print $ maximum [magnitude $ x `sAdd` y | x <- snums, y <- snums]

sAdd :: Snum -> Snum -> Snum
sAdd = (reduce.) . sAddRaw

sAddRaw :: Snum -> Snum -> Snum
sAddRaw x y = Pair x y

reduce :: Snum -> Snum
reduce s = case explode s of
  Just s' -> reduce s'
  Nothing -> case split s of
    Just s' -> reduce s'
    Nothing -> s

explode :: Snum -> Maybe Snum
explode s = explode' 0 s >>= Just . fst3
  where
    explode' :: Int -> Snum -> Maybe (Snum, Int, Int)
    explode' 4 (Pair (Lit x) (Lit y)) = Just (Lit 0, x, y)
    explode' depth (Pair l r) = case explode' (depth + 1) l of
      -- left subtree exploded
      Just (newL, x, y) -> Just (Pair newL (addToLeftMost y r), x, 0)
      Nothing -> explode' (depth + 1) r
                 >>= (\(newR, x, y) -> Just (Pair (addToRightMost x l) newR, 0, y))
        -- case explode' (depth +1) r of
        -- Just (newR, x, y) -> Just (Pair (addToRightMost x l) newR, 0, y)
        -- Nothing -> Nothing
    explode' _ _ = Nothing

addToLeftMost, addToRightMost :: Int -> Snum -> Snum
addToLeftMost x (Lit y) = Lit (x+y)
addToLeftMost x (Pair l r) = Pair (addToLeftMost x l) r

addToRightMost x (Lit y) = Lit (x+y)
addToRightMost x (Pair l r) = Pair l (addToRightMost x r)


split :: Snum -> Maybe Snum
split (Lit n) | n >= 10 = let l = n `div` 2
                              r = (n+1) `div` 2 in
                  Just $ Pair (Lit l) (Lit r)
              | otherwise = Nothing
split (Pair l r) = case split l of
  Just newL -> Just (Pair newL r)
  Nothing -> case split r of
    Just newR -> Just (Pair l newR)
    Nothing -> Nothing

magnitude :: Snum -> Int
magnitude (Lit n) = n
magnitude (Pair l r) = (magnitude l * 3) + (magnitude r * 2)

parseSnum :: String -> (Snum, String)
parseSnum ('[':rest)= let (left, leftRest) = parseSnum rest
                          (right, rightRest) = parseSnum $ tail leftRest in
                        (Pair left right, tail rightRest)
parseSnum (x:rest) = (Lit $ digitToInt x, rest)

parse = fst . parseSnum
