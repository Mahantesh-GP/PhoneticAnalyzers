# Phonetic Analyzers System - How It Works

## What It Does
The system finds people even when their names are spelled differently. For example, it can match "John Smith" with "Jon Smyth" or "Catherine" with "Katherine".

## Data Ingestion Flow

### Step 1: Data Comes In
- Person data (Name, Email, Phone) enters the system via API or file upload
- Example: `{ "FirstName": "Catherine", "LastName": "Johnson", "Email": "cjohnson@email.com" }`

### Step 2: Phonetic Encoding
The system creates multiple "sound codes" for each name:
```
"Catherine" becomes:
- Soundex: C365
- Metaphone: K0RN
- DoubleMetaphone: K0RN, KTRN
- NYSIIS: CATARN
```

### Step 3: Storage
Both original name AND all phonetic codes are saved:
```
Database Record:
- FirstName: "Catherine"
- LastName: "Johnson"  
- Email: "cjohnson@email.com"
- FirstName_Soundex: "C365"
- FirstName_Metaphone: "K0RN"
- LastName_Soundex: "J525"
- etc...
```

## Search Process

### Step 1: User Searches
User types: "Katherine Jonson" (note the misspellings)

### Step 2: Generate Search Codes
System creates phonetic codes for search term:
```
"Katherine" → Soundex: C365, Metaphone: K0RN
"Jonson" → Soundex: J525, Metaphone: JNSN
```

### Step 3: Match Against Database
System finds records where phonetic codes match:
```
Search Soundex "C365" matches stored "C365" ✓
Search Soundex "J525" matches stored "J525" ✓
```

### Step 4: Return Results
```
Found: Catherine Johnson (95% match)
- FirstName match: Katherine ≈ Catherine (same sound)
- LastName match: Jonson ≈ Johnson (same sound)
```

## Real-World Example

### Ingestion
```
Input: "Muhammad Ali"
Stored as:
- Original: "Muhammad Ali" 
- Phonetic codes: MHM, AL, etc.
```

### Search Scenarios
All these searches find "Muhammad Ali":
- "Mohamed Ali" ✓
- "Mohammed Alley" ✓  
- "Muhamed Ally" ✓
- "Mohamad Alee" ✓

## Business Value
- **Find duplicates**: Same person with different spellings
- **Improve search**: Users don't need exact spelling
- **Data quality**: Identify potential matches for review

## System Architecture

### Simple Flow
```
Data Input → Phonetic Encoding → Database Storage
     ↓              ↓               ↓
Search Input → Generate Codes → Match & Return Results
```

### Technology Stack
- **Frontend**: Web application for search interface
- **Backend**: Azure Functions for processing
- **Database**: PostgreSQL for data storage
- **Algorithms**: Multiple phonetic encoding methods

## Performance
- **Speed**: Searches complete in milliseconds
- **Accuracy**: 90%+ match rate for name variations
- **Scale**: Handles millions of records efficiently