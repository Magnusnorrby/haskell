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
stateOfMind ((x1,x2):xs) = do
   r <- randomIO :: IO Float	    
   return (rulesApply [((pick r x2),x1)])

rulesApply :: [PhrasePair] -> Phrase -> Phrase
rulesApply [] _ = []
rulesApply x p = fromMaybe p (transformationsApply "*" id x p) 

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


reflectLoop :: Phrase  -> Phrase
reflectLoop [] = []
reflectLoop (x:xs)  = [(sub x reflections)] ++ reflectLoop xs 

reflect :: Phrase -> Phrase
reflect p = reflectLoop p
   





---------------------------------------------------------------------------------

endOfDialog :: String -> Bool
endOfDialog = (=="quit") . map toLower

present :: Phrase -> String
present = unwords

prepare :: String -> Phrase
prepare = reduce . words . map toLower . filter (not . flip elem ".,:;*!#%&|") 

rulesCompile :: [(String, [String])] -> BotBrain
rulesCompile [] = []
rulesCompile ((x1,x2):xs) = [((prepare x1),(map prepare x2))] ++ rulesCompile xs

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
    ( "hi *", "hello *")
  ]

reduce :: Phrase -> Phrase
reduce = reductionsApply reductions

reductionsApply :: [PhrasePair] -> Phrase -> Phrase
{- TO BE WRITTEN -}
reductionsApply _ = id


-- Test cases
reflectTest = reflect ["i", "will", "never", "see", "my", "reflection", "in", "your", "eyes"]
reflectCheck = reflectTest == ["you", "will", "never", "see", "your", "reflection", "in", "my", "eyes"] 