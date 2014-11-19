module Chatterbot where
import Utilities
import Pattern
import System.Random
import Data.Char
import Data.Maybe


chatterbot :: String -> [(String, [String])] -> IO ()
chatterbot botName botRules = do
    putStrLn ("\n\nHi! I am " ++ botName ++ ". How are you?")
    botloop
  where
    brain = rulesCompile botRules
    botloop = do
      putStr "\n: "
      question <- getLine
      answer <- stateOfMind brain
      putStrLn (botName ++ ": " ++ (present . answer . prepare) question)
      if (not . endOfDialog) question then botloop else return ()

--------------------------------------------------------

type Phrase = [String]
type PhrasePair = (Phrase, Phrase)
type BotBrain = [(Phrase, [Phrase])]


--------------------------------------------------------

stateOfMind :: BotBrain -> IO (Phrase -> Phrase)
stateOfMind brain = do
   r <- randomIO :: IO Float	    
   return (rulesApply [(x1,(pick r x2)) | (x1,x2) <- brain])

rulesApply :: [PhrasePair] -> Phrase -> Phrase
rulesApply [] _ = []
rulesApply x p
   | transformationsApply "*" reflect x p == Nothing = p
   | otherwise = fromJust (transformationsApply "*" reflect x p) 

reflections =
  [ ("am",     "are"),
    ("was",    "were"),
    ("i",      "you"),
    ("i'm",    "you are"),
    ("i'd",    "you would"),
    ("i've",   "you have"),
    ("i'll",   "you will"),
    ("my",     "your"),
    ("me",     "you"),
    ("are",    "am"),
    ("you're", "i am"),
    ("you've", "i have"),
    ("you'll", "i will"),
    ("your",   "my"),
    ("yours",  "mine"),
    ("you",    "me")
  ]

sub :: String-> [(String,String)] -> String
sub p [] = p
sub p (x:xs)
    | p==fst x = snd x  
    | otherwise = sub p xs


reflect :: Phrase -> Phrase
reflect [] = []
reflect (x:xs) = [(sub x reflections)] ++ reflect xs 

   





---------------------------------------------------------------------------------

endOfDialog :: String -> Bool
endOfDialog = (=="quit") . map toLower

present :: Phrase -> String
present = unwords

prepare :: String -> Phrase
prepare = reduce . words . map toLower . 
          filter (not . flip elem ".,:;*!#%&|") 

lower :: String -> Phrase
lower = words . map toLower

rulesCompile :: [(String, [String])] -> BotBrain
rulesCompile = foldr (\(x1,x2) xs -> (lower x1 ,map words x2):xs) []


--------------------------------------


reductions :: [PhrasePair]
reductions = (map.map2) (words, words)
  [ ( "please *", "*" ),
    ( "can you *", "*" ),
    ( "could you *", "*" ),
    ( "tell me if you are *", "are you *" ),
    ( "tell me who * is", "who is *" ),
    ( "tell me what * is", "what is *" ),
    ( "do you know who * is", "who is *" ),
    ( "do you know what * is", "what is *" ),
    ( "are you very *", "are you *" ),
    ( "i am very *", "i am *" ),
    ( "i'm very *", "i'm *" ),
    ( "hi *", "hello *")
  ]

reduce :: Phrase -> Phrase
reduce = reductionsApply reductions

removeDouble :: Phrase -> Phrase
removeDouble [] = []
removeDouble (x:xs) 
    | null xs = [x] ++ removeDouble xs
    | head xs == x = [] ++ removeDouble xs
    | otherwise = [x] ++ removeDouble xs

reductionsApply :: [PhrasePair] -> Phrase -> Phrase
reductionsApply [] _ = []
reductionsApply x p
   | transformationsApply "*" reduce x (removeDouble p) == Nothing = p
   | otherwise = fromJust (transformationsApply "*" reduce x (removeDouble p)) 


-- Test cases
reflectTest = reflect ["i", "will", "never", "see", "my", "reflection", "in", "your", "eyes"]
reflectCheck = reflectTest == ["you", "will", "never", "see", "your", "reflection", "in", "my", "eyes"] 