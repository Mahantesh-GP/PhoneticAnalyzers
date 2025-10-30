# UI Integration Guide - PhoneticAnalyzers API

This guide shows how to consume the PhoneticAnalyzers API from various UI frameworks.

## 🚀 **API Base URL**

**Local Development:**
```
http://localhost:7071/api
```

**Azure Production:**
```
https://your-function-app.azurewebsites.net/api
```

## 📋 **Available API Endpoints**

| Endpoint | Method | Description | Request Body |
|----------|--------|-------------|--------------|
| `/health` | GET | Health check | None |
| `/ingest` | POST | Add single person | PersonData JSON |
| `/ingest/batch` | POST | Add multiple persons | BatchData JSON |
| `/search` | GET | Search by name | Query parameters |
| `/person/{id}` | GET | Get person by ID | None |

---

## 🌐 **JavaScript/TypeScript Examples**

### **Basic Fetch API**

```javascript
// API Client Class
class PhoneticAnalyzersClient {
    constructor(baseUrl = 'http://localhost:7071/api') {
        this.baseUrl = baseUrl;
    }

    // Health Check
    async healthCheck() {
        const response = await fetch(`${this.baseUrl}/health`);
        return response.json();
    }

    // Add Single Person
    async addPerson(personData) {
        const response = await fetch(`${this.baseUrl}/ingest`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(personData)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    }

    // Search Persons
    async searchPersons(name, maxResults = 10) {
        const params = new URLSearchParams({
            name: name,
            maxResults: maxResults.toString()
        });
        
        const response = await fetch(`${this.baseUrl}/search?${params}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    }

    // Batch Add Persons
    async addPersonsBatch(persons) {
        const response = await fetch(`${this.baseUrl}/ingest/batch`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ persons })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    }
}

// Usage Example
const apiClient = new PhoneticAnalyzersClient();

// Add a person
try {
    const result = await apiClient.addPerson({
        externalId: 'emp001',
        fullName: 'John Smith',
        expandNicknames: true
    });
    console.log('Person added:', result);
} catch (error) {
    console.error('Error adding person:', error);
}

// Search for persons
try {
    const results = await apiClient.searchPersons('Jon Smyth', 5);
    console.log('Search results:', results);
} catch (error) {
    console.error('Error searching:', error);
}
```

### **TypeScript Interfaces**

```typescript
// TypeScript Type Definitions
interface PersonData {
    externalId: string;
    fullName: string;
    expandNicknames?: boolean;
}

interface PersonIngestResult {
    personId: number;
    message: string;
    wasCreated: boolean;
    phoneticCodes: {
        primary: string | null;
        alternate: string | null;
        beiderMorseCodes: string[];
    };
    warnings: string[];
}

interface SearchResult {
    query: string;
    totalResults: number;
    maxResults: number;
    executionTime: number;
    results: PersonSearchResult[];
}

interface PersonSearchResult {
    personId: number;
    externalId: string;
    fullName: string;
    normalizedName: string;
    similarityScore: number;
    matchType: string;
    phoneticCodes?: {
        doubleMetaphone: {
            primary: string | null;
            alternate: string | null;
        };
        beiderMorse: string[];
    };
}

interface HealthCheckResult {
    status: string;
    timestamp: string;
    version: string;
}

// TypeScript Client
class PhoneticAnalyzersClient {
    constructor(private baseUrl: string = 'http://localhost:7071/api') {}

    async healthCheck(): Promise<HealthCheckResult> {
        const response = await fetch(`${this.baseUrl}/health`);
        return response.json();
    }

    async addPerson(personData: PersonData): Promise<PersonIngestResult> {
        const response = await fetch(`${this.baseUrl}/ingest`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(personData)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    }

    async searchPersons(name: string, maxResults: number = 10): Promise<SearchResult> {
        const params = new URLSearchParams({
            name,
            maxResults: maxResults.toString()
        });
        
        const response = await fetch(`${this.baseUrl}/search?${params}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    }
}
```

---

## ⚛️ **React Examples**

### **React Hook for API**

```jsx
// hooks/usePhoneticAnalyzers.js
import { useState, useCallback } from 'react';

export const usePhoneticAnalyzers = (baseUrl = 'http://localhost:7071/api') => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const apiCall = useCallback(async (url, options = {}) => {
        setLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`${baseUrl}${url}`, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers,
                },
                ...options,
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            return data;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [baseUrl]);

    const addPerson = useCallback(async (personData) => {
        return apiCall('/ingest', {
            method: 'POST',
            body: JSON.stringify(personData),
        });
    }, [apiCall]);

    const searchPersons = useCallback(async (name, maxResults = 10) => {
        const params = new URLSearchParams({ name, maxResults });
        return apiCall(`/search?${params}`);
    }, [apiCall]);

    const healthCheck = useCallback(async () => {
        return apiCall('/health');
    }, [apiCall]);

    return {
        loading,
        error,
        addPerson,
        searchPersons,
        healthCheck,
    };
};
```

### **React Component Example**

```jsx
// components/PersonSearch.jsx
import React, { useState } from 'react';
import { usePhoneticAnalyzers } from '../hooks/usePhoneticAnalyzers';

const PersonSearch = () => {
    const [searchTerm, setSearchTerm] = useState('');
    const [results, setResults] = useState([]);
    const { loading, error, searchPersons, addPerson } = usePhoneticAnalyzers();

    const handleSearch = async (e) => {
        e.preventDefault();
        if (!searchTerm.trim()) return;

        try {
            const searchResults = await searchPersons(searchTerm, 10);
            setResults(searchResults.results);
        } catch (err) {
            console.error('Search failed:', err);
        }
    };

    const handleAddPerson = async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        
        try {
            await addPerson({
                externalId: formData.get('externalId'),
                fullName: formData.get('fullName'),
                expandNicknames: true
            });
            alert('Person added successfully!');
            e.target.reset();
        } catch (err) {
            console.error('Add person failed:', err);
        }
    };

    return (
        <div className="person-search">
            <h2>Phonetic Name Search</h2>
            
            {/* Add Person Form */}
            <form onSubmit={handleAddPerson} className="add-form">
                <h3>Add New Person</h3>
                <input name="externalId" placeholder="External ID" required />
                <input name="fullName" placeholder="Full Name" required />
                <button type="submit" disabled={loading}>Add Person</button>
            </form>

            {/* Search Form */}
            <form onSubmit={handleSearch} className="search-form">
                <h3>Search Persons</h3>
                <input 
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    placeholder="Enter name to search..."
                    required
                />
                <button type="submit" disabled={loading}>
                    {loading ? 'Searching...' : 'Search'}
                </button>
            </form>

            {/* Error Display */}
            {error && <div className="error">Error: {error}</div>}

            {/* Results */}
            <div className="results">
                <h3>Search Results ({results.length})</h3>
                {results.map((person) => (
                    <div key={person.personId} className="person-card">
                        <h4>{person.fullName}</h4>
                        <p><strong>ID:</strong> {person.externalId}</p>
                        <p><strong>Similarity:</strong> {(person.similarityScore * 100).toFixed(1)}%</p>
                        <p><strong>Match Type:</strong> {person.matchType}</p>
                        {person.phoneticCodes && (
                            <div className="phonetic-codes">
                                <strong>Phonetic Codes:</strong>
                                <br />Primary: {person.phoneticCodes.doubleMetaphone.primary}
                                <br />Alternate: {person.phoneticCodes.doubleMetaphone.alternate}
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
};

export default PersonSearch;
```

---

## 🅰️ **Angular Examples**

### **Angular Service**

```typescript
// services/phonetic-analyzers.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface PersonData {
    externalId: string;
    fullName: string;
    expandNicknames?: boolean;
}

export interface PersonIngestResult {
    personId: number;
    message: string;
    wasCreated: boolean;
    phoneticCodes: {
        primary: string | null;
        alternate: string | null;
        beiderMorseCodes: string[];
    };
    warnings: string[];
}

export interface SearchResult {
    query: string;
    totalResults: number;
    results: PersonSearchResult[];
}

export interface PersonSearchResult {
    personId: number;
    externalId: string;
    fullName: string;
    similarityScore: number;
    matchType: string;
}

@Injectable({
    providedIn: 'root'
})
export class PhoneticAnalyzersService {
    private baseUrl = 'http://localhost:7071/api';

    constructor(private http: HttpClient) {}

    healthCheck(): Observable<any> {
        return this.http.get(`${this.baseUrl}/health`);
    }

    addPerson(personData: PersonData): Observable<PersonIngestResult> {
        return this.http.post<PersonIngestResult>(`${this.baseUrl}/ingest`, personData);
    }

    searchPersons(name: string, maxResults: number = 10): Observable<SearchResult> {
        const params = new HttpParams()
            .set('name', name)
            .set('maxResults', maxResults.toString());

        return this.http.get<SearchResult>(`${this.baseUrl}/search`, { params });
    }

    addPersonsBatch(persons: PersonData[]): Observable<any> {
        return this.http.post(`${this.baseUrl}/ingest/batch`, { persons });
    }
}
```

### **Angular Component**

```typescript
// components/person-search.component.ts
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { PhoneticAnalyzersService, PersonSearchResult } from '../services/phonetic-analyzers.service';

@Component({
    selector: 'app-person-search',
    template: `
        <div class="person-search">
            <h2>Phonetic Name Search</h2>
            
            <!-- Add Person Form -->
            <form [formGroup]="addForm" (ngSubmit)="onAddPerson()">
                <h3>Add New Person</h3>
                <input formControlName="externalId" placeholder="External ID" />
                <input formControlName="fullName" placeholder="Full Name" />
                <button type="submit" [disabled]="loading || addForm.invalid">Add Person</button>
            </form>

            <!-- Search Form -->
            <form [formGroup]="searchForm" (ngSubmit)="onSearch()">
                <h3>Search Persons</h3>
                <input formControlName="searchTerm" placeholder="Enter name to search..." />
                <button type="submit" [disabled]="loading || searchForm.invalid">
                    {{ loading ? 'Searching...' : 'Search' }}
                </button>
            </form>

            <!-- Results -->
            <div class="results" *ngIf="searchResults.length > 0">
                <h3>Search Results ({{ searchResults.length }})</h3>
                <div *ngFor="let person of searchResults" class="person-card">
                    <h4>{{ person.fullName }}</h4>
                    <p><strong>ID:</strong> {{ person.externalId }}</p>
                    <p><strong>Similarity:</strong> {{ (person.similarityScore * 100) | number:'1.1-1' }}%</p>
                    <p><strong>Match Type:</strong> {{ person.matchType }}</p>
                </div>
            </div>

            <!-- Error Display -->
            <div *ngIf="error" class="error">{{ error }}</div>
        </div>
    `,
    styles: [`
        .person-search { padding: 20px; }
        .person-card { 
            border: 1px solid #ccc; 
            margin: 10px 0; 
            padding: 15px; 
            border-radius: 5px; 
        }
        .error { color: red; margin: 10px 0; }
        form { margin: 20px 0; }
        input { margin: 5px; padding: 8px; }
        button { margin: 5px; padding: 8px 16px; }
    `]
})
export class PersonSearchComponent {
    addForm: FormGroup;
    searchForm: FormGroup;
    searchResults: PersonSearchResult[] = [];
    loading = false;
    error: string | null = null;

    constructor(
        private fb: FormBuilder,
        private phoneticService: PhoneticAnalyzersService
    ) {
        this.addForm = this.fb.group({
            externalId: ['', Validators.required],
            fullName: ['', Validators.required]
        });

        this.searchForm = this.fb.group({
            searchTerm: ['', Validators.required]
        });
    }

    onAddPerson(): void {
        if (this.addForm.valid) {
            this.loading = true;
            this.error = null;

            const personData = {
                ...this.addForm.value,
                expandNicknames: true
            };

            this.phoneticService.addPerson(personData).subscribe({
                next: (result) => {
                    alert('Person added successfully!');
                    this.addForm.reset();
                    this.loading = false;
                },
                error: (err) => {
                    this.error = err.message;
                    this.loading = false;
                }
            });
        }
    }

    onSearch(): void {
        if (this.searchForm.valid) {
            this.loading = true;
            this.error = null;

            const searchTerm = this.searchForm.get('searchTerm')?.value;

            this.phoneticService.searchPersons(searchTerm, 10).subscribe({
                next: (result) => {
                    this.searchResults = result.results;
                    this.loading = false;
                },
                error: (err) => {
                    this.error = err.message;
                    this.loading = false;
                }
            });
        }
    }
}
```

---

## 🔧 **CORS Configuration**

If you're accessing the API from a browser-based app, you may need to configure CORS in your Azure Function:

```csharp
// In Program.cs, add CORS configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowWebApp", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "https://your-webapp.com")
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// In your function class, add CORS headers to responses
var response = req.CreateResponse(HttpStatusCode.OK);
response.Headers.Add("Access-Control-Allow-Origin", "*");
response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.Headers.Add("Access-Control-Allow-Headers", "Content-Type");
```

---

## 🔐 **Authentication (Optional)**

If you want to secure your API, you can add authentication:

```javascript
// Client with API key authentication
class SecurePhoneticAnalyzersClient {
    constructor(baseUrl, apiKey) {
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
    }

    async makeRequest(endpoint, options = {}) {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                'x-functions-key': this.apiKey,
                ...options.headers,
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return response.json();
    }

    async addPerson(personData) {
        return this.makeRequest('/ingest', {
            method: 'POST',
            body: JSON.stringify(personData)
        });
    }
}

// Usage with API key
const secureClient = new SecurePhoneticAnalyzersClient(
    'https://your-function-app.azurewebsites.net/api',
    'your-api-key-here'
);
```

---

## 📱 **Mobile Examples (React Native)**

```javascript
// React Native with Axios
import axios from 'axios';

class MobilePhoneticClient {
    constructor(baseUrl = 'http://localhost:7071/api') {
        this.client = axios.create({
            baseURL: baseUrl,
            timeout: 10000,
            headers: {
                'Content-Type': 'application/json',
            }
        });
    }

    async addPerson(personData) {
        const response = await this.client.post('/ingest', personData);
        return response.data;
    }

    async searchPersons(name, maxResults = 10) {
        const response = await this.client.get('/search', {
            params: { name, maxResults }
        });
        return response.data;
    }
}

// Usage in React Native component
const PersonSearchScreen = () => {
    const [searchResults, setSearchResults] = useState([]);
    const [loading, setLoading] = useState(false);
    const client = new MobilePhoneticClient();

    const handleSearch = async (searchTerm) => {
        setLoading(true);
        try {
            const results = await client.searchPersons(searchTerm);
            setSearchResults(results.results);
        } catch (error) {
            Alert.alert('Error', 'Search failed');
        } finally {
            setLoading(false);
        }
    };

    return (
        <View>
            <TextInput 
                placeholder="Enter name to search"
                onSubmitEditing={(e) => handleSearch(e.nativeEvent.text)}
            />
            <FlatList
                data={searchResults}
                keyExtractor={(item) => item.personId.toString()}
                renderItem={({ item }) => (
                    <View>
                        <Text>{item.fullName}</Text>
                        <Text>Similarity: {(item.similarityScore * 100).toFixed(1)}%</Text>
                    </View>
                )}
            />
        </View>
    );
};
```

---

## 🧪 **Testing Your Integration**

### **Simple HTML Test Page**

```html
<!DOCTYPE html>
<html>
<head>
    <title>PhoneticAnalyzers Test</title>
</head>
<body>
    <h1>PhoneticAnalyzers API Test</h1>
    
    <div>
        <h3>Add Person</h3>
        <input id="externalId" placeholder="External ID" />
        <input id="fullName" placeholder="Full Name" />
        <button onclick="addPerson()">Add Person</button>
    </div>
    
    <div>
        <h3>Search</h3>
        <input id="searchName" placeholder="Search Name" />
        <button onclick="searchPersons()">Search</button>
    </div>
    
    <div id="results"></div>

    <script>
        const API_BASE = 'http://localhost:7071/api';

        async function addPerson() {
            const externalId = document.getElementById('externalId').value;
            const fullName = document.getElementById('fullName').value;
            
            try {
                const response = await fetch(`${API_BASE}/ingest`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ externalId, fullName, expandNicknames: true })
                });
                
                const result = await response.json();
                alert('Person added: ' + JSON.stringify(result));
            } catch (error) {
                alert('Error: ' + error.message);
            }
        }

        async function searchPersons() {
            const searchName = document.getElementById('searchName').value;
            
            try {
                const response = await fetch(`${API_BASE}/search?name=${encodeURIComponent(searchName)}&maxResults=5`);
                const result = await response.json();
                
                document.getElementById('results').innerHTML = 
                    '<h3>Results:</h3><pre>' + JSON.stringify(result, null, 2) + '</pre>';
            } catch (error) {
                alert('Error: ' + error.message);
            }
        }
    </script>
</body>
</html>
```

---

## 🚀 **Next Steps**

1. **Start the API:** Run `.\start-functions.bat` to start your PhoneticAnalyzers API
2. **Choose your UI framework:** Use the examples above for your preferred technology
3. **Test the integration:** Start with the simple HTML example
4. **Handle errors:** Implement proper error handling and loading states
5. **Add authentication:** Secure your API if needed for production

The API is designed to be consumed easily by any UI framework. Choose the example that matches your technology stack and customize it for your needs!