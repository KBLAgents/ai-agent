from pydantic import BaseModel
from typing import List

class Analytics(BaseModel):
    """
    Analytics model for retrieving entity analytics data.
    """
    id: str
    company_name: str
    company_description: str
    value_analysis: str
    key_facts: List["Analytics.KeyFact"]

    class KeyFact(BaseModel):
        """
        KeyFact model for retrieving key facts.
        """
        name: str
        value: str