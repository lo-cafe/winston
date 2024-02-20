import dotenv from "dotenv";
dotenv.config();

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

// Function for fetching chat completions from OpenAI using the GPT-4 model or similar
async function fetchChatCompletion(prompt) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-4", // Specify the desired model here, assuming "gpt-4". Adjust according to availability and your API plan.
      messages: [
        {
          role: "system",
          content: "You are a helpful assistant.",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
    }),
  });

  const responseBody = await response.json();
  if (!response.ok) {
    throw new Error(
      `API request failed: ${response.status} - ${response.statusText} - ${JSON.stringify(responseBody)}`,
    );
  }

  if (
    !responseBody.choices ||
    responseBody.choices.length === 0 ||
    !responseBody.choices[0].message.content.trim()
  ) {
    throw new Error("Failed to generate completion.");
  }

  return responseBody.choices[0].message.content.trim();
}

export default async function processItems(items) {
  return Promise.all(
    items.map(async (item) => {
      try {
        const generalPrompt = `Generate one single suggestion. Don't say anything except the single suggestion. Don't wrap the suggestion in quotes.`;
        const subjectPrompt = `Generate a short, user-friendly new feature title based on the following feature commit message: "${item.subject}". I want just the title, WITHOUT any announcement like "New feature:" in the beggining of the phrase. ${generalPrompt}`;
        const descriptionPrompt = `Rewrite the following feature commit message description to be short, user - friendly: "${item.description.length < 5 ? item.subject : item.description}".${generalPrompt} `;
        const iconPrompt = `Given a feature about "${item.subject}", suggest an appropriate icon name from the SF Symbols collection.${generalPrompt} `;

        const subjectProm = fetchChatCompletion(subjectPrompt);
        const descriptionProm = fetchChatCompletion(descriptionPrompt);
        const iconProm = fetchChatCompletion(iconPrompt);

        const [subject, description, icon] = await Promise.all([
          subjectProm,
          descriptionProm,
          iconProm,
        ]);

        return { subject, description, icon };
      } catch (error) {
        console.error(`Failed to process item: ${item.subject} `, error);
        throw error;
      }
    }),
  );
}

const items = [
  {
    subject: "adding new btn for creating new post",
    description:
      "adds a new fab in posts feed that enables many actions including post creation",
  },
];
