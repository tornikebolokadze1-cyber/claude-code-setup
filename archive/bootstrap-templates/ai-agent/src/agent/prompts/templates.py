"""Prompt templates for different agent nodes."""

from langchain_core.prompts import ChatPromptTemplate

PLANNING_TEMPLATE = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a planning assistant. Break down the user's request into steps."),
        ("human", "Plan how to answer this: {input}"),
    ]
)

REVIEW_TEMPLATE = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a quality reviewer. Check the answer for accuracy and completeness.",
        ),
        ("human", "Review this answer:\n\n{answer}\n\nOriginal question: {question}"),
    ]
)
