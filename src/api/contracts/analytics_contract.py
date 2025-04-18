from pydantic import BaseModel
from typing import List

class AnalyticsResponse(BaseModel):
    """
    Analytics model for retrieving entity analytics data.
    """
    name: str
    description: str
    competitors_and_value_analysis: str
    keyfacts: "AnalyticsResponse.KeyFact"

    class KeyFact(BaseModel):
        """
        KeyFact model for retrieving key facts.
        """
        market_cap: str
        eps: str
        pe: str
        dividend_yield: str
        dividend_frequency: str
        annual_payout: str
        industry: str
        
class AnalyticsRequest(BaseModel):
    """
    Analytics model for retrieving entity analytics data.
    """
    user_role: str
    company_name: str