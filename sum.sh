#!/bin/bash

# Input: YouTube video URL
video_url=$1
max_tokens=700
gptPrompt="Write in about 300-500 words a concise summary of the video transcript provided. Include the most important and relevant information. Don't just say what the video is about, instead, act like a student and learn from the video and then present those learnings in an easy to understand and yet actionable way for me. Here is the transcript:"
/opt/homebrew/bin/yt-dlp --skip-download --write-subs --write-auto-subs  --sub-lang en --sub-format ttml --convert-subs srt --output "transcript.%(ext)s" "$video_url" && sed -i '' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]$/d' -e '/^[[:digit:]]\{1,3\}$/d' -e 's/<[^>]*>//g' ./transcript.en.srt && sed -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' ~/Desktop/transcript.en.srt > ~/Desktop/output.txt
tr '\n' ' ' < ~/Desktop/output.txt > ~/Desktop/output1.txt

# # Step 3: Use OpenAI API to get the summary using the GPT-3.5 model
transcript=$(cat output1.txt)
# echo $transcript
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{\"model\": \"gpt-3.5-turbo\",\"messages\": [{
    \"role\": \"user\", 
    \"content\": \"$gptPrompt $transcript\"
    }],
    \"temperature\": 0.7,
    \"max_tokens\": $max_tokens, 
    \"stream\": false}" > ~/Desktop/output2.txt
response=$(cat ~/Desktop/output2.txt | /opt/homebrew/bin/jq -R '.' | /opt/homebrew/bin/jq -s '.' | /opt/homebrew/bin/jq -r 'join("")' | /opt/homebrew/bin/jq -r '.choices[0].message.content')
echo $response > ~/Desktop/Summary.txt
rm ~/Desktop/transcript.en.srt
rm ~/Desktop/output.txt
rm ~/Desktop/output1.txt
rm ~/Desktop/output2.txt
echo $response
